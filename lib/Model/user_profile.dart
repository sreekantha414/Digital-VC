import 'dart:convert';

enum CardType { user, other, valid, invalid }

class VisitingCard {
  final int? id;
  final Map<String, String> fields;
  final List<String> extras;
  final String? qrData;
  final CardType type;

  VisitingCard({this.id, required this.fields, this.extras = const [], this.qrData, required this.type});

  VisitingCard copyWith({int? id, Map<String, String>? fields, List<String>? extras, String? qrData, CardType? type}) {
    return VisitingCard(
      id: id ?? this.id,
      fields: fields ?? this.fields,
      extras: extras ?? this.extras,
      qrData: qrData ?? this.qrData,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'fields': jsonEncode(fields),
    'extras': jsonEncode(extras),
    'qrData': qrData,
    'type': type.name, // Save enum as string
  };

  factory VisitingCard.fromMap(Map<String, dynamic> map) {
    return VisitingCard(
      id: map['id'] as int?,
      fields: Map<String, String>.from(jsonDecode(map['fields'] as String)),
      extras: List<String>.from(jsonDecode(map['extras'] as String)),
      qrData: map['qrData'] as String?,
      type: CardType.values.firstWhere((e) => e.name == map['type'], orElse: () => CardType.other),
    );
  }

  @override
  String toString() {
    return 'VisitingCard(id: $id, fields: $fields, extras: $extras, qrData: $qrData, type: $type)';
  }
}

// import 'dart:convert';
//
// class VisitingCard {
//   final int? id;
//   final Map<String, String> fields; // Label → Value, e.g. "Email": "test@example.com"
//   final List<String> extras; // Any leftover or unstructured lines
//   final String? qrData; // Raw QR payload, if scanned
//
//   VisitingCard({this.id, required this.fields, this.extras = const [], this.qrData});
//
//   VisitingCard copyWith({int? id, Map<String, String>? fields, List<String>? extras, String? qrData}) {
//     return VisitingCard(id: id ?? this.id, fields: fields ?? this.fields, extras: extras ?? this.extras, qrData: qrData ?? this.qrData);
//   }
//
//   Map<String, dynamic> toMap() => {'id': id, 'fields': jsonEncode(fields), 'extras': jsonEncode(extras), 'qrData': qrData};
//
//   factory VisitingCard.fromMap(Map<String, dynamic> map) {
//     return VisitingCard(
//       id: map['id'] as int?,
//       fields: Map<String, String>.from(jsonDecode(map['fields'] as String)),
//       extras: List<String>.from(jsonDecode(map['extras'] as String)),
//       qrData: map['qrData'] as String?,
//     );
//   }
//
//   /// Optional: Convert to readable string
//   @override
//   String toString() {
//     return 'VisitingCard(id: $id, fields: $fields, extras: $extras, qrData: $qrData)';
//   }
// }
