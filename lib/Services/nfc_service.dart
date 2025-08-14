import 'dart:convert';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart' as flutter_nfc;
import 'package:ndef/record.dart' as flutter_nfc; // ⬅️ Required for NDEFRecord
import 'dart:typed_data' show Uint8List; // Explicitly use this Uint8List
import 'dart:convert'; // For utf8.encode

class NFCService {
  static Future<bool> isAvailable() async {
    try {
      final availability = await flutter_nfc.FlutterNfcKit.nfcAvailability;
      return availability == flutter_nfc.NFCAvailability.available;
    } catch (e) {
      print('❌ Error checking NFC availability: $e');
      return false;
    }
  }

  /// Reads a text payload from the first NDEF record.
  static Future<String?> readNdef() async {
    try {
      // Check NFC availability
      final availability = await flutter_nfc.FlutterNfcKit.nfcAvailability;
      if (availability != flutter_nfc.NFCAvailability.available) {
        print('🔴 NFC not available on this device.');
        return null;
      }

      // Start polling for NFC tag
      await flutter_nfc.FlutterNfcKit.poll();

      // Read NDEF records
      final records = await flutter_nfc.FlutterNfcKit.readNDEFRecords();

      if (records.isEmpty) {
        print('🟡 No NDEF records found.');
        return null;
      }

      final payload = records.first.payload;

      if (payload == null || payload.isEmpty) {
        print('🟡 Empty payload in NDEF record.');
        return null;
      }

      // Extract language code length from first byte
      final langCodeLength = payload[0];
      if (payload.length <= langCodeLength) {
        print('🔴 Invalid payload format.');
        return null;
      }

      // Extract actual text from payload
      final textBytes = payload.sublist(1 + langCodeLength);
      final text = utf8.decode(textBytes);

      print('✅ NFC Read: $text');
      return text;
    } catch (e) {
      print('❌ NFC read error: $e');
      return null;
    } finally {
      // Always attempt to finish the session
      try {
        await flutter_nfc.FlutterNfcKit.finish();
      } catch (e) {
        print('⚠️ NFC finish error (safe to ignore): $e');
      }
    }
  }

  /// Writes a simple text record to the tag.
  static Future<bool> writeNdef(String text) async {
    try {
      // Wait for NFC tag to be detected
      await flutter_nfc.FlutterNfcKit.poll();

      // Build NDEF text payload
      final payload = _buildTextPayload(text);

      // Write the record
      await flutter_nfc.FlutterNfcKit.writeNDEFRecords([
        flutter_nfc.NDEFRecord(
          tnf: flutter_nfc.TypeNameFormat.nfcWellKnown,
          type: Uint8List.fromList(utf8.encode('T')), // "T" = text record
          payload: Uint8List.fromList(payload),
        ),
      ]);

      print("✅ NFC write complete");
      return true; // success
    } catch (e) {
      print('❌ NFC write error: $e');
      return false; // failed
    } finally {
      try {
        await flutter_nfc.FlutterNfcKit.finish();
      } catch (e) {
        print("⚠️ NFC finish error: $e");
      }
    }
  }

  // static Future<void> writeNdef(String text) async {
  //   try {
  //     await flutter_nfc.FlutterNfcKit.poll();
  //     final List<int> payload = _buildTextPayload(text);
  //
  //     Uint8List _toExplicitUint8List(List<int> bytes) => Uint8List.fromList(bytes);
  //
  //     await flutter_nfc.FlutterNfcKit.writeNDEFRecords([
  //       flutter_nfc.NDEFRecord(
  //         tnf: flutter_nfc.TypeNameFormat.nfcWellKnown,
  //         type: _toExplicitUint8List(utf8.encode('T')),
  //         payload: _toExplicitUint8List(payload),
  //       ),
  //     ]);
  //
  //     await flutter_nfc.FlutterNfcKit.finish();
  //   } catch (e) {
  //     print('NFC write error: $e');
  //     await flutter_nfc.FlutterNfcKit.finish();
  //   }
  // }
}

List<int> _buildTextPayload(String text) {
  const langCode = 'en';
  final langCodeBytes = utf8.encode(langCode);
  final textBytes = utf8.encode(text);
  final statusByte = langCodeBytes.length;
  return [statusByte, ...langCodeBytes, ...textBytes];
}
