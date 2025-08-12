import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:visiting_card_app/main.dart';

import '../Ai Agent/Bussiness_card_agent.dart';
import '../Database/database.dart';
import '../Model/user_profile.dart';
import '../utils/app_helper.dart';

class ImageOCRService {
  static Future<VisitingCard?> scanAndSave({required bool fromGallery}) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: fromGallery ? ImageSource.gallery : ImageSource.camera);
    if (picked == null) return null;

    final input = InputImage.fromFile(File(picked.path));

    // OCR
    final textRec = GoogleMlKit.vision.textRecognizer();
    final vision = await textRec.processImage(input);
    await textRec.close();
    final rawText = vision.text;

    // QR Code
    final barcodeScanner = GoogleMlKit.vision.barcodeScanner();
    final barcodes = await barcodeScanner.processImage(input);
    await barcodeScanner.close();
    String? qrData;
    for (final barcode in barcodes) {
      if (barcode.format == BarcodeFormat.qrCode && barcode.rawValue != null) {
        qrData = barcode.rawValue;
        break;
      }
    }

    // AI Parse
    final visitingCard = await BusinessCardAgent.parseCardText(rawText);
    if (visitingCard == null) return null;

    final hasValidData = visitingCard.fields.values.any((v) => v.trim().isNotEmpty) || (qrData?.trim().isNotEmpty ?? false);

    if (!hasValidData) return null;

    // Metadata
    final metadata = await AppHelper.getScanMetadata(fromGallery ? "Gallery OCR" : "Camera OCR");
    logger.w(metadata);
    final finished = visitingCard.copyWith(
      type: CardType.other,
      qrData: qrData,
      extras: [
        ...visitingCard.extras,
        'Valid: ${visitingCard.type == CardType.valid}',
        'Scanned via: ${metadata['scan_method']}',
        'Time: ${metadata['timestamp']}',
        if (metadata['location'] != null) 'Location: ${metadata['location']['latitude']}, ${metadata['location']['longitude']}',
      ],
    );

    final id = await DBService.insertVisitingCard(finished);
    return finished.copyWith(id: id);
  }
}
