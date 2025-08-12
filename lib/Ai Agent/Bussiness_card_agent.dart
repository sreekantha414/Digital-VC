import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../Model/user_profile.dart';

const String apiKey = 'AIzaSyBIfCa5qTvvB2CWRjqqU4pOsNPdtI1iDzE';

class BusinessCardAgent {
  static const String _systemInstruction = '''
You are an assistant that processes raw OCR text from scanned cards.

Your job: Identify and extract structured data ONLY from professional business or visiting cards.

====================
✅ VALID CARD RULES:
====================
- Must belong to a real person with a professional role.
- Must contain at least 2 of the following:
  • Full Name
  • Job Title / Designation
  • Company / Organization
  • Work Email
  • Business Phone Number (10+ digits)

====================
❌ INVALID CARD IF:
====================
- Any government-issued ID (Aadhaar, PAN, Passport, License, etc.).
- Membership, loyalty, or payment cards.
- Branding-only cards with no person/role.
- Cards with only personal details but no job/company info.
- Contains keywords: ["Aadhaar", "Government of India", "DOB", "PAN", "Income Tax", "Voter", "UID", "EID", "Card Number", "Govt", "License", "Passport"]

====================
📦 JSON OUTPUT FORMAT:
====================
Return only a JSON object with this exact structure:

{
  "fields": {
    "name": "",
    "jobTitle": "",
    "company": "",
    "email": "",
    "phone": "",
    "website": "",
    "address": "",
    "category": "",
    "description": "",
    "hours": "",
    "facebook": "",
    "instagram": "",
    "linkedin": "",
    "youtube": "",
    "twitter": "",
    "catalog": "",
    "tags": ""
  },
  "validCard": true/false
}

IMPORTANT:
- Use **only** these exact keys for "fields". Never invent new keys.
- If a field is not found on the card, leave it as an empty string "".
- All values should be plain text with no extra formatting.
- Never output additional text outside the JSON.

====================
TASK:
====================
Given the OCR text, fill in the JSON above. Keep "validCard" true or false based on the rules.
''';

  static final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey, systemInstruction: Content.text(_systemInstruction));

  static Future<VisitingCard?> parseCardText(String ocrText) async {
    try {
      final prompt = '''
Raw OCR text:
\"\"\"
$ocrText
\"\"\"

Extract structured fields and validity. JSON only.
''';

      final result = await model.generateContent([Content.text(prompt)]);
      final raw = result.text?.trim() ?? '';

      final start = raw.indexOf('{');
      final end = raw.lastIndexOf('}');
      if (start == -1 || end == -1) return null;

      final jsonStr = raw.substring(start, end + 1);
      final decoded = json.decode(jsonStr);

      if (decoded is! Map<String, dynamic>) return null;

      final rawFields = decoded['fields'] as Map<String, dynamic>? ?? {};
      final fields = rawFields.map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''));
      final valid = decoded['validCard'] == true;

      return VisitingCard(fields: fields, extras: [], type: valid ? CardType.valid : CardType.invalid);
    } catch (e) {
      print('❌ BusinessCardAgent.parseCardText error: $e');
      return null;
    }
  }
}
