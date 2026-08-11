import 'dart:convert';

enum ToolCategory {
  flight,
  hotel,
  itinerary,
  packing,
  expenses,
  documents,
  photos,
  notes,
}

extension ToolCategoryX on ToolCategory {
  String get id => name;

  static ToolCategory? fromId(String id) {
    for (final c in ToolCategory.values) {
      if (c.id == id) return c;
    }
    return null;
  }
}

class ToolEntry {
  final String id;
  final String tripId;
  final String category;
  final String title;
  final String subtitle;
  final String extra;
  final double amount;
  final bool checked;
  final DateTime createdAt;

  const ToolEntry({
    required this.id,
    required this.tripId,
    required this.category,
    required this.title,
    this.subtitle = '',
    this.extra = '',
    this.amount = 0,
    this.checked = false,
    required this.createdAt,
  });

  ToolEntry copyWith({
    String? title,
    String? subtitle,
    String? extra,
    double? amount,
    bool? checked,
  }) {
    return ToolEntry(
      id: id,
      tripId: tripId,
      category: category,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      extra: extra ?? this.extra,
      amount: amount ?? this.amount,
      checked: checked ?? this.checked,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tripId': tripId,
        'category': category,
        'title': title,
        'subtitle': subtitle,
        'extra': extra,
        'amount': amount,
        'checked': checked,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ToolEntry.fromJson(Map<String, dynamic> json) => ToolEntry(
        id: json['id'] as String,
        tripId: json['tripId'] as String,
        category: json['category'] as String,
        title: json['title'] as String? ?? '',
        subtitle: json['subtitle'] as String? ?? '',
        extra: json['extra'] as String? ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        checked: json['checked'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  static String encodeList(List<ToolEntry> items) =>
      jsonEncode(items.map((e) => e.toJson()).toList());

  static List<ToolEntry> decodeList(String raw) {
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => ToolEntry.fromJson(e as Map<String, dynamic>)).toList();
  }
}

const defaultPackingItems = [
  'Passport & ID',
  'Phone charger',
  'Clothes',
  'Toiletries',
  'Medicine',
  'Snacks',
  'Umbrella',
  'Camera',
];
