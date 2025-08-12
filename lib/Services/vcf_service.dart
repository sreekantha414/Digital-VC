import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../Model/user_profile.dart'; // VisitingCard is assumed to be in this file

class VCFService {
  static String _makeVCard(VisitingCard card) {
    final name = card.fields['name'] ?? 'Unknown';
    final phone = card.fields['phone'] ?? '';
    final email = card.fields['email'] ?? '';
    final company = card.fields['company'] ?? '';
    final address = card.fields['address'] ?? '';

    return '''
BEGIN:VCARD
VERSION:3.0
FN:$name
ORG:$company
TEL:$phone
EMAIL:$email
ADR:;;$address
END:VCARD
''';
  }

  /// Writes a .vcf file and returns its local path
  static Future<String> createVcfFile(VisitingCard card) async {
    final dir = await getApplicationDocumentsDirectory();

    final rawName = card.fields['name'] ?? 'contact';
    final sanitizedName = rawName.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');

    final file = File('${dir.path}/$sanitizedName.vcf');
    await file.writeAsString(_makeVCard(card));

    return file.path;
  }
}
