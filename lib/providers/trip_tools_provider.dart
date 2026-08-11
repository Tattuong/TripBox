import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../core/services/storage_service.dart';
import '../models/trip_tool_data.dart';

class TripToolsProvider extends ChangeNotifier {
  static const _storageKey = 'tb_tool_entries';

  final _uuid = const Uuid();
  List<ToolEntry> _entries = [];
  bool _initialized = false;

  bool get initialized => _initialized;
  List<ToolEntry> get entries => List.unmodifiable(_entries);

  Future<void> init() async {
    if (_initialized) return;
    final raw = await StorageService.instance.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      _entries = ToolEntry.decodeList(raw);
    }
    _initialized = true;
    notifyListeners();
  }

  List<ToolEntry> forTripCategory(String tripId, String category) {
    return _entries.where((e) => e.tripId == tripId && e.category == category).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<ToolEntry> get allPhotos => _entries
      .where((e) => e.category == ToolCategory.photos.id && e.extra.isNotEmpty)
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  double expenseTotal(String tripId) {
    return _entries
        .where((e) => e.tripId == tripId && e.category == ToolCategory.expenses.id)
        .fold(0.0, (s, e) => s + e.amount);
  }

  Future<void> ensurePackingDefaults(String tripId) async {
    final existing = forTripCategory(tripId, ToolCategory.packing.id);
    if (existing.isNotEmpty) return;
    for (final item in defaultPackingItems) {
      _entries.add(ToolEntry(
        id: _uuid.v4(),
        tripId: tripId,
        category: ToolCategory.packing.id,
        title: item,
        createdAt: DateTime.now(),
      ));
    }
    await _save();
    notifyListeners();
  }

  Future<ToolEntry> add({
    required String tripId,
    required String category,
    required String title,
    String subtitle = '',
    String extra = '',
    double amount = 0,
  }) async {
    final entry = ToolEntry(
      id: _uuid.v4(),
      tripId: tripId,
      category: category,
      title: title,
      subtitle: subtitle,
      extra: extra,
      amount: amount,
      createdAt: DateTime.now(),
    );
    _entries.insert(0, entry);
    await _save();
    notifyListeners();
    return entry;
  }

  Future<void> toggleChecked(String id) async {
    final i = _entries.indexWhere((e) => e.id == id);
    if (i < 0) return;
    _entries[i] = _entries[i].copyWith(checked: !_entries[i].checked);
    await _save();
    notifyListeners();
  }

  Future<void> update(String id, {String? title, String? subtitle, String? extra, double? amount}) async {
    final i = _entries.indexWhere((e) => e.id == id);
    if (i < 0) return;
    _entries[i] = _entries[i].copyWith(
      title: title,
      subtitle: subtitle,
      extra: extra,
      amount: amount,
    );
    await _save();
    notifyListeners();
  }

  Future<void> remove(String id) async {
    _entries.removeWhere((e) => e.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    await StorageService.instance.saveString(_storageKey, ToolEntry.encodeList(_entries));
  }
}
