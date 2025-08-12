import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

/// A generic representation of a scanned visiting card.
class VisitingCard {
  final Map<String, String> fields; // labeled key->value pairs
  final List<String> extras; // unlabeled lines
  final String? qrData; // if the card contained a QR code

  VisitingCard({required this.fields, this.extras = const [], this.qrData});
}

/// Service that uses ML Kit to scan both text and QR/barcode from a card image.
class CardScannerService {
  static final _textRecognizer = GoogleMlKit.vision.textRecognizer();
  static final _barcodeScanner = GoogleMlKit.vision.barcodeScanner(); // default scans all formats

  /// Scans an image from camera or gallery, returns a VisitingCard with parsed data.
  static Future<VisitingCard?> scanCard({bool fromGallery = false}) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: fromGallery ? ImageSource.gallery : ImageSource.camera, imageQuality: 80);
    if (picked == null) return null;
    final input = InputImage.fromFile(File(picked.path));

    // 1. Scan for QR codes and filter
    final rawBarcodes = await _barcodeScanner.processImage(input);
    final qrBarcodes = rawBarcodes.where((b) => b.format == BarcodeFormat.qrCode).toList();
    String? qrData;
    if (qrBarcodes.isNotEmpty) {
      qrData = qrBarcodes.first.rawValue;
    }

    // 2. OCR scan
    final textResult = await _textRecognizer.processImage(input);

    // 3. Parse lines into fields/extras
    final lines = textResult.blocks.expand((b) => b.lines).map((l) => l.text.trim()).where((l) => l.isNotEmpty).toList();

    final Map<String, String> fields = {};
    final List<String> extras = [];

    for (var line in lines) {
      if (line.contains('@') && !fields.containsKey('Email')) {
        fields['Email'] = line;
      } else if (RegExp(r'^(?:\+?\d[\d -]{6,}\d)\$').hasMatch(line) && !fields.containsKey('Phone')) {
        fields['Phone'] = line;
      } else if ((line.toLowerCase().contains('inc') || line.toLowerCase().contains('ltd') || line.toLowerCase().contains('company')) &&
          !fields.containsKey('Company')) {
        fields['Company'] = line;
      } else if (!fields.containsKey('Name')) {
        fields['Name'] = line;
      } else if (line.toLowerCase().contains('street') || line.toLowerCase().contains('road') || line.toLowerCase().contains('india')) {
        fields['Address'] = line;
      } else {
        extras.add(line);
      }
    }

    if (fields.isEmpty && extras.isEmpty && qrData == null) return null;
    return VisitingCard(fields: fields, extras: extras, qrData: qrData);
  }
}

/// A camera-based scanning screen for physical cards
class CardScanScreen extends StatefulWidget {
  @override
  _CardScanScreenState createState() => _CardScanScreenState();
}

class _CardScanScreenState extends State<CardScanScreen> {
  bool _loading = false;
  VisitingCard? _card;

  Future<void> _startScan(bool fromGallery) async {
    setState(() => _loading = true);
    final scanned = await CardScannerService.scanCard(fromGallery: fromGallery);
    setState(() {
      _card = scanned;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return Center(child: CircularProgressIndicator());
    if (_card == null) {
      return Center(child: ElevatedButton.icon(icon: Icon(Icons.camera_alt), label: Text('Scan Card'), onPressed: () => _startScan(false)));
    }

    // Display dynamic UI based on scanned fields
    return Scaffold(
      appBar: AppBar(title: Text('Review Card')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_card!.qrData != null) ...[
                Text('Detected QR code:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Center(child: Text(_card!.qrData!)),
                Divider(),
              ],
              Text('Detected Fields:', style: TextStyle(fontWeight: FontWeight.bold)),
              ..._card!.fields.entries.map((e) => ListTile(title: Text(e.key), subtitle: Text(e.value), leading: Icon(Icons.label))),
              if (_card!.extras.isNotEmpty) ...[
                Divider(),
                Text('Unclassified Lines:', style: TextStyle(fontWeight: FontWeight.bold)),
                ..._card!.extras.map((e) => Text('- ' + e)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
