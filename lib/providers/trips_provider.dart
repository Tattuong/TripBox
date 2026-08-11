import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../core/constants/iap_constants.dart';
import '../core/services/storage_service.dart';
import '../models/trip.dart';
import '../models/trip_member.dart';

class TripsProvider extends ChangeNotifier {
  static const _tripsKey = 'tb_trips';
  static const _recentKey = 'tb_recent_viewed';
  static const _onboardingKey = 'tb_onboarding_complete';
  static const _profileNameKey = 'tb_profile_name';
  static const _profileLocationKey = 'tb_profile_location';
  static const _seedClearedKey = 'tb_seed_cleared_v2';
  static const _wishlistKey = 'tb_wishlist';

  final _uuid = const Uuid();
  List<TripEntry> _trips = [];
  List<String> _recentViewedIds = [];
  bool _onboardingComplete = false;
  String _profileName = 'Alfonso Schleifer';
  String _profileLocation = 'Inglewood, US';
  List<String> _wishlistIds = [];
  bool _initialized = false;

  List<TripEntry> get trips => List.unmodifiable(_trips);
  List<TripEntry> get upcomingTrips => _trips.where((t) => t.isUpcoming && t.endDate.isAfter(DateTime.now())).toList();
  TripEntry? get nextUpcomingTrip {
    final list = List<TripEntry>.from(upcomingTrips)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    return list.isEmpty ? null : list.first;
  }
  List<TripEntry> get allTrips => _trips;
  bool get onboardingComplete => _onboardingComplete;
  String get profileName => _profileName;
  String get profileLocation => _profileLocation;
  bool get initialized => _initialized;

  int get tripCount => _trips.length;

  int tripLimit(bool hasPremium) => hasPremium ? IapConstants.premiumTripLimit : IapConstants.freeTripLimit;

  List<TripEntry> get recentlyViewed {
    return _recentViewedIds
        .map((id) => _trips.where((t) => t.id == id).firstOrNull)
        .whereType<TripEntry>()
        .toList();
  }

  List<TripEntry> get wishlistTrips =>
      _wishlistIds.map((id) => tripById(id)).whereType<TripEntry>().toList();

  bool isWishlisted(String tripId) => _wishlistIds.contains(tripId);

  TripEntry? tripById(String id) => _trips.where((t) => t.id == id).firstOrNull;

  /// Unique travel companions across all trips (excluding owner duplicates by name).
  List<TripMember> get allFriends {
    final seen = <String>{};
    final friends = <TripMember>[];
    for (final trip in _trips) {
      for (final member in trip.members) {
        if (member.isOwner) continue;
        final key = member.name.trim().toLowerCase();
        if (key.isEmpty || seen.contains(key)) continue;
        seen.add(key);
        friends.add(member);
      }
    }
    friends.sort((a, b) => a.name.compareTo(b.name));
    return friends;
  }

  Future<void> init() async {
    if (_initialized) return;
    final raw = await StorageService.instance.getString(_tripsKey);
    if (raw != null && raw.isNotEmpty) {
      _trips = TripEntry.decodeList(raw);
      await _migrateOwnerNames();
      await _clearLegacySeedTrips();
    } else {
      _trips = [];
    }
    _recentViewedIds = await StorageService.instance.getStringList(_recentKey) ?? [];
    _onboardingComplete = await StorageService.instance.getBool(_onboardingKey) ?? false;
    _profileName = await StorageService.instance.getString(_profileNameKey) ?? _profileName;
    _profileLocation = await StorageService.instance.getString(_profileLocationKey) ?? _profileLocation;
    _wishlistIds = await StorageService.instance.getStringList(_wishlistKey) ?? [];
    _initialized = true;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _onboardingComplete = true;
    await StorageService.instance.saveBool(_onboardingKey, true);
    notifyListeners();
  }

  Future<void> updateProfile({String? name, String? location}) async {
    if (name != null) {
      _profileName = name;
      await StorageService.instance.saveString(_profileNameKey, name);
      _syncOwnerNames(name);
      await _saveTrips();
    }
    if (location != null) {
      _profileLocation = location;
      await StorageService.instance.saveString(_profileLocationKey, location);
    }
    notifyListeners();
  }

  Future<void> _clearLegacySeedTrips() async {
    final cleared = await StorageService.instance.getBool(_seedClearedKey) ?? false;
    if (cleared) return;
    final before = _trips.length;
    _trips.removeWhere(
      (t) => t.id.startsWith('sample_') || t.id.startsWith('pop_'),
    );
    if (_trips.length != before) await _saveTrips();
    await StorageService.instance.saveBool(_seedClearedKey, true);
  }

  Future<void> _migrateOwnerNames() async {
    var changed = false;
    _trips = _trips.map((trip) {
      final ownerIdx = trip.members.indexWhere((m) => m.isOwner);
      if (ownerIdx < 0) return trip;
      final owner = trip.members[ownerIdx];
      if (owner.name == 'You') {
        changed = true;
        final updated = List<TripMember>.from(trip.members);
        updated[ownerIdx] = owner.copyWith(name: _profileName);
        return trip.copyWith(members: updated);
      }
      return trip;
    }).toList();
    if (changed) await _saveTrips();
  }

  void _syncOwnerNames(String name) {
    _trips = _trips.map((trip) {
      final ownerIdx = trip.members.indexWhere((m) => m.isOwner);
      if (ownerIdx < 0) return trip;
      final updated = List<TripMember>.from(trip.members);
      updated[ownerIdx] = updated[ownerIdx].copyWith(name: name);
      return trip.copyWith(members: updated);
    }).toList();
  }

  Future<bool> addTrip({
    required String title,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    String imageUrl = '',
    int hotelCount = 1,
    int destinationCount = 1,
    bool hasPremium = false,
  }) async {
    if (_trips.length >= tripLimit(hasPremium)) return false;
    final owner = TripMember(id: _uuid.v4(), name: _profileName, isOwner: true);
    final trip = TripEntry(
      id: _uuid.v4(),
      title: title,
      destination: destination,
      startDate: startDate,
      endDate: endDate,
      imageUrl: imageUrl,
      hotelCount: hotelCount,
      destinationCount: destinationCount,
      members: [owner],
      isUpcoming: startDate.isAfter(DateTime.now().subtract(const Duration(days: 1))),
      createdAt: DateTime.now(),
    );
    _trips.insert(0, trip);
    await _saveTrips();
    notifyListeners();
    return true;
  }

  Future<bool> toggleWishlist(String tripId) async {
    if (tripById(tripId) == null) return false;
    if (_wishlistIds.contains(tripId)) {
      _wishlistIds.remove(tripId);
    } else {
      _wishlistIds.insert(0, tripId);
    }
    await StorageService.instance.saveStringList(_wishlistKey, _wishlistIds);
    notifyListeners();
    return _wishlistIds.contains(tripId);
  }

  Future<void> updateTripCover(String tripId, String imagePath) async {
    final idx = _trips.indexWhere((t) => t.id == tripId);
    if (idx < 0) return;
    _trips[idx] = _trips[idx].copyWith(imageUrl: imagePath);
    await _saveTrips();
    notifyListeners();
  }

  Future<bool> addMember(String tripId, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;
    final idx = _trips.indexWhere((t) => t.id == tripId);
    if (idx < 0) return false;
    final trip = _trips[idx];
    final exists = trip.members.any((m) => m.name.trim().toLowerCase() == trimmed.toLowerCase());
    if (exists) return false;
    final member = TripMember(id: _uuid.v4(), name: trimmed);
    _trips[idx] = trip.copyWith(members: [...trip.members, member]);
    await _saveTrips();
    notifyListeners();
    return true;
  }

  Future<void> removeMember(String tripId, String memberId) async {
    final idx = _trips.indexWhere((t) => t.id == tripId);
    if (idx < 0) return;
    final trip = _trips[idx];
    final member = trip.members.where((m) => m.id == memberId).firstOrNull;
    if (member == null || member.isOwner) return;
    _trips[idx] = trip.copyWith(members: trip.members.where((m) => m.id != memberId).toList());
    await _saveTrips();
    notifyListeners();
  }

  String inviteMessageFor(TripEntry trip) {
    final names = trip.members.map((m) => m.name).join(', ');
    return 'Join my trip "${trip.title}" on TripBox!\n'
        '${trip.destination}\n'
        '${trip.dateRange}\n'
        'Travelers: $names\n'
        'Download TripBox to plan together!';
  }

  Future<void> deleteTrip(String id) async {
    _trips.removeWhere((t) => t.id == id);
    _recentViewedIds.remove(id);
    _wishlistIds.remove(id);
    await _saveTrips();
    await StorageService.instance.saveStringList(_recentKey, _recentViewedIds);
    await StorageService.instance.saveStringList(_wishlistKey, _wishlistIds);
    notifyListeners();
  }

  Future<void> markViewed(String id) async {
    _recentViewedIds.remove(id);
    _recentViewedIds.insert(0, id);
    if (_recentViewedIds.length > 10) {
      _recentViewedIds = _recentViewedIds.sublist(0, 10);
    }
    await StorageService.instance.saveStringList(_recentKey, _recentViewedIds);
    notifyListeners();
  }

  List<TripEntry> search(String query) {
    if (query.isEmpty) return _trips;
    final q = query.toLowerCase();
    return _trips.where((t) =>
        t.title.toLowerCase().contains(q) ||
        t.destination.toLowerCase().contains(q)).toList();
  }

  Future<void> _saveTrips() async {
    await StorageService.instance.saveString(_tripsKey, TripEntry.encodeList(_trips));
  }
}
