import 'dart:convert';

class TripMember {
  final String id;
  final String name;
  final bool isOwner;

  const TripMember({
    required this.id,
    required this.name,
    this.isOwner = false,
  });

  String get initial {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed[0].toUpperCase();
  }

  String get firstName {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts.first : name;
  }

  TripMember copyWith({String? name, bool? isOwner}) {
    return TripMember(
      id: id,
      name: name ?? this.name,
      isOwner: isOwner ?? this.isOwner,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isOwner': isOwner,
      };

  factory TripMember.fromJson(Map<String, dynamic> json) => TripMember(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        isOwner: json['isOwner'] as bool? ?? false,
      );

  static String encodeList(List<TripMember> members) =>
      jsonEncode(members.map((m) => m.toJson()).toList());
}
