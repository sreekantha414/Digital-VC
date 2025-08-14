import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:visiting_card_app/Screens/scan_qr_code.dart';
import 'package:visiting_card_app/main.dart';
import 'package:visiting_card_app/utils/app_helper.dart';
import '../Database/database.dart';
import '../Model/user_profile.dart';
import '../services/image_ocr_service.dart';
import '../services/nfc_service.dart';
import 'display_profile.dart';
import 'dart:convert';

class ScanMethodsScreen extends StatefulWidget {
  @override
  _ScanMethodsScreenState createState() => _ScanMethodsScreenState();
}

class _ScanMethodsScreenState extends State<ScanMethodsScreen> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrController;
  bool _loading = false;

  void _onData(String raw, {required String method}) async {
    try {
      // Decode JSON (handle double-encoded case)
      dynamic decoded = json.decode(raw);
      if (decoded is String) {
        decoded = json.decode(decoded);
      }

      final map = Map<String, dynamic>.from(decoded);
      final visitingCard = VisitingCard.fromMap(map);

      final metadata = await AppHelper.getScanMetadata(method);
      final cardWithMetadata = visitingCard.copyWith(
        type: CardType.other,
        extras: [
          ...visitingCard.extras,
          "Scanned via: ${metadata['scan_method'] ?? 'Unknown'}",
          "Time: ${metadata['timestamp'] ?? 'Unknown'}",
          if (metadata['location'] != null) "Location: ${metadata['location']['latitude']}, ${metadata['location']['longitude']}",
        ],
      );
      logger.w(cardWithMetadata);
      // Check if the card exists
      final existingCard = await DBService.getVisitingCardById(cardWithMetadata.id ?? 0);
      if (existingCard != null) {
        await DBService.updateVisitingCard(cardWithMetadata);
      } else {
        await DBService.insertVisitingCard(cardWithMetadata);
      }
      Navigator.push(context, MaterialPageRoute(builder: (_) => DisplayProfileScreen(card: cardWithMetadata)));
    } catch (e) {
      print('Error decoding QR/AI data: $e');
      print('Raw data: $raw');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to parse and save profile.')));
    }
  }

  // void _onData(String raw, {required String method}) async {
  //   try {
  //     // Try decoding JSON string (even if it's nested once)
  //     dynamic decoded = json.decode(raw);
  //     if (decoded is String) {
  //       decoded = json.decode(decoded); // handle double-encoded
  //     }
  //
  //     final map = Map<String, dynamic>.from(decoded);
  //     final visitingCard = VisitingCard.fromMap(map);
  //
  //     final metadata = await AppHelper.getScanMetadata(method);
  //     logger.w(metadata);
  //     final cardWithMetadata = visitingCard.copyWith(
  //       type: CardType.other,
  //       extras: [
  //         ...visitingCard.extras,
  //         "Scanned via: ${metadata['scan_method']}",
  //         "Time: ${metadata['timestamp']}",
  //         if (metadata['location'] != null) "Location: ${metadata['location']['latitude']}, ${metadata['location']['longitude']}",
  //       ],
  //     );
  //     logger.w(cardWithMetadata);
  //     print(cardWithMetadata);
  //     await DBService.insertVisitingCard(cardWithMetadata);
  //
  //     // await DBService.insertVisitingCard(visitingCard);
  //
  //     Navigator.push(context, MaterialPageRoute(builder: (_) => DisplayProfileScreen(card: visitingCard)));
  //   } catch (e) {
  //     print('Error decoding QR/AI data: $e');
  //     print('Raw data: $raw');
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to parse and save profile.')));
  //   }
  // }

  // Future<void> _scanNFC() async {
  //   setState(() => _loading = true);
  //   final isAvailable = await NFCService.isAvailable();
  //   if (!isAvailable) {
  //     setState(() => _loading = false);
  //     _showDialog("NFC Unavailable", "Your device doesn't support NFC or it's turned off.");
  //     return;
  //   }
  //
  //   final raw = await NFCService.readNdef();
  //   logger.w(raw);
  //   setState(() => _loading = false);
  //   if (raw != null) _onData(raw, method: 'NFC');
  // }
  Future<void> _scanNFC() async {
    setState(() => _loading = true);

    final isAvailable = await NFCService.isAvailable();
    if (!isAvailable) {
      setState(() => _loading = false);
      _showDialog("NFC Unavailable", "Your device doesn't support NFC or it's turned off.");
      return;
    }

    // Try reading NFC tag
    final raw = await NFCService.readNdef();
    logger.w("NFC Raw Read: $raw");

    if (raw != null && raw.startsWith("VCARD_APP::")) {
      // Visiting card found → parse & save
      final jsonData = raw.replaceFirst("VCARD_APP::", "");
      setState(() => _loading = false);
      _onData(jsonData, method: 'NFC');
    } else {
      // No visiting card found → write my own card
      final allCards = await DBService.getAllVisitingCards();
      final userCards = allCards.where((card) => card.type == CardType.user);

      if (userCards.first == null) {
        setState(() => _loading = false);
        _showDialog("No Card Found", "Please create your own visiting card first.");
        return;
      }

      final jsonCardData = jsonEncode(userCards.first.toMap());
      final writeSuccess = await NFCService.writeNdef("VCARD_APP::$jsonCardData");

      setState(() => _loading = false);

      // if (writeSuccess) {
      //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✅ Visiting card written to NFC tag")));
      // } else {
      //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Failed to write visiting card to NFC tag")));
      // }
    }
  }

  Future<void> _scanCardImage({required bool fromGallery}) async {
    setState(() => _loading = true);
    final card = await ImageOCRService.scanAndSave(fromGallery: fromGallery);
    setState(() => _loading = false);
    if (card != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => DisplayProfileScreen(card: card)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No valid card detected')));
    }
  }

  void _showCameraOrGalleryOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text("Scan via Camera"),
                onTap: () {
                  Navigator.pop(context);
                  _scanCardImage(fromGallery: false);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo),
                title: Text("Scan a Card"),
                onTap: () {
                  Navigator.pop(context);
                  _scanCardImage(fromGallery: true);
                },
              ),
            ],
          ),
    );
  }

  void _showQRAndCardScanner() async {
    final raw = await Navigator.push(context, MaterialPageRoute(builder: (_) => QRScannerScreen()));

    if (raw != null && raw is String) {
      _onData(raw, method: 'QR');
    }
  }

  void _showDialog(String title, String msg) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(title),
            content: Text(msg),
            actions: [TextButton(child: Text("OK", style: TextStyle(color: Colors.deepPurple)), onPressed: () => Navigator.pop(context))],
          ),
    );
  }

  @override
  void dispose() {
    qrController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('Scan Your Card'), centerTitle: true),
      body:
          _loading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 10),
                    Text(
                      "Choose a method to scan your visiting card",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "You can scan via NFC, QR/Camera, or Image OCR.",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                    SizedBox(height: 30),
                    Expanded(
                      child: ListView(
                        children: [
                          _scanCard(
                            icon: Icons.nfc,
                            title: "Scan via NFC",
                            description: "Tap your card to the device",
                            color: Colors.deepPurple,
                            onTap: _scanNFC,
                          ),
                          _scanCard(
                            icon: Icons.qr_code_scanner,
                            title: "QR / Camera",
                            description: "Scan QR or Card using Camera",
                            color: Colors.green,
                            onTap: _showQRAndCardScanner,
                          ),
                          _scanCard(
                            icon: Icons.image,
                            title: "From Image",
                            description: "Scan image or select from gallery",
                            color: Colors.orange,
                            onTap: _showCameraOrGalleryOptions,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _scanCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Icon(icon, color: color)),
        title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        subtitle: Text(description),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: onTap,
      ),
    );
  }
}
