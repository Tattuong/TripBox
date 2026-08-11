import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import 'trip_member.dart';
import 'dart:convert';

class TripEntry {
  final String id;
  final String title;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final String imageUrl;
  final int hotelCount;
  final int destinationCount;
  final List<TripMember> members;
  final bool isUpcoming;
  final String category;
  final DateTime createdAt;

  const TripEntry({
    required this.id,
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.imageUrl,
    this.hotelCount = 0,
    this.destinationCount = 0,
    this.members = const [],
    this.isUpcoming = true,
    this.category = 'general',
    required this.createdAt,
  });

  int get dayCount => endDate.difference(startDate).inDays + 1;

  String get dateRange {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final s = '${months[startDate.month - 1]} ${startDate.day}';
    final e = '${months[endDate.month - 1]} ${endDate.day}';
    return '$s → $e';
  }

  TripEntry copyWith({
    String? title,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    String? imageUrl,
    int? hotelCount,
    int? destinationCount,
    List<TripMember>? members,
    bool? isUpcoming,
    String? category,
  }) {
    return TripEntry(
      id: id,
      title: title ?? this.title,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      imageUrl: imageUrl ?? this.imageUrl,
      hotelCount: hotelCount ?? this.hotelCount,
      destinationCount: destinationCount ?? this.destinationCount,
      members: members ?? this.members,
      isUpcoming: isUpcoming ?? this.isUpcoming,
      category: category ?? this.category,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'destination': destination,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'imageUrl': imageUrl,
        'hotelCount': hotelCount,
        'destinationCount': destinationCount,
        'members': members.map((m) => m.toJson()).toList(),
        'isUpcoming': isUpcoming,
        'category': category,
        'createdAt': createdAt.toIso8601String(),
      };

  factory TripEntry.fromJson(Map<String, dynamic> json) => TripEntry(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        destination: json['destination'] as String? ?? '',
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: DateTime.parse(json['endDate'] as String),
        imageUrl: json['imageUrl'] as String? ?? '',
        hotelCount: json['hotelCount'] as int? ?? 0,
        destinationCount: json['destinationCount'] as int? ?? 0,
        members: _parseMembers(json),
        isUpcoming: json['isUpcoming'] as bool? ?? true,
        category: json['category'] as String? ?? 'general',
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  static String encodeList(List<TripEntry> trips) =>
      jsonEncode(trips.map((t) => t.toJson()).toList());

  static List<TripEntry> decodeList(String raw) {
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => TripEntry.fromJson(e as Map<String, dynamic>)).toList();
  }

  static List<TripMember> _parseMembers(Map<String, dynamic> json) {
    if (json['members'] is List) {
      return (json['members'] as List)
          .map((e) => TripMember.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    final legacy = (json['memberAvatars'] as List<dynamic>?)?.cast<String>() ?? [];
    return legacy.asMap().entries.map((e) {
      final label = e.value.trim();
      final name = label.length == 1 ? _legacyLetterName(label) : label;
      return TripMember(id: 'legacy_${e.key}', name: name, isOwner: e.key == 0);
    }).toList();
  }

  static String _legacyLetterName(String letter) {
    const names = {
      'A': 'Anna',
      'B': 'Ben',
      'C': 'Chris',
      'D': 'David',
      'E': 'Emma',
      'F': 'Felix',
      'G': 'Grace',
      'H': 'Henry',
      'I': 'Ivy',
      'J': 'Jack',
    };
    return names[letter.toUpperCase()] ?? 'Guest $letter';
  }
}

class TravelCategory {
  final String id;
  final String labelKey;
  final String emoji;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const TravelCategory({
    required this.id,
    required this.labelKey,
    required this.emoji,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}

class TravelCategories {
  TravelCategories._();

  static const all = [
    TravelCategory(id: 'flight', labelKey: 'catFlight', emoji: '✈️', icon: Icons.flight, color: AppColors.catFlightFg, bgColor: AppColors.catFlightBg),
    TravelCategory(id: 'hotel', labelKey: 'catHotel', emoji: '🏨', icon: Icons.hotel, color: AppColors.catHotelFg, bgColor: AppColors.catHotelBg),
    TravelCategory(id: 'itinerary', labelKey: 'catItinerary', emoji: '🗺', icon: Icons.map, color: AppColors.catItineraryFg, bgColor: AppColors.catItineraryBg),
    TravelCategory(id: 'packing', labelKey: 'catPacking', emoji: '🎒', icon: Icons.backpack, color: AppColors.catPackingFg, bgColor: AppColors.catPackingBg),
    TravelCategory(id: 'expenses', labelKey: 'catExpenses', emoji: '💰', icon: Icons.payments, color: AppColors.catExpensesFg, bgColor: AppColors.catExpensesBg),
    TravelCategory(id: 'documents', labelKey: 'catDocuments', emoji: '📄', icon: Icons.description, color: AppColors.catDocumentsFg, bgColor: AppColors.catDocumentsBg),
    TravelCategory(id: 'photos', labelKey: 'catPhotos', emoji: '📸', icon: Icons.photo_camera, color: AppColors.catPhotosFg, bgColor: AppColors.catPhotosBg),
    TravelCategory(id: 'notes', labelKey: 'catNotes', emoji: '📝', icon: Icons.note_alt, color: AppColors.catNotesFg, bgColor: AppColors.catNotesBg),
  ];

  static TravelCategory? byId(String id) {
    for (final c in all) {
      if (c.id == id) return c;
    }
    return null;
  }
}
