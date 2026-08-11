import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/navigation/app_navigator.dart';
import '../../core/utils/category_access.dart';
import '../../models/trip.dart';
import '../../models/trip_tool_data.dart';
import '../../providers/shell_provider.dart';
import '../../providers/shop_provider.dart';
import '../../providers/trip_tools_provider.dart';
import '../../providers/trips_provider.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/app_ui.dart';
import '../../widgets/trip_design.dart';
import '../shop/shop_screen.dart';
import '../trips/create_trip_sheet.dart';

class CategoryToolScreen extends StatefulWidget {
  final String categoryId;

  const CategoryToolScreen({super.key, required this.categoryId});

  @override
  State<CategoryToolScreen> createState() => _CategoryToolScreenState();
}

class _CategoryToolScreenState extends State<CategoryToolScreen> {
  String? _selectedTripId;
  final _picker = ImagePicker();

  ToolCategory? get category => ToolCategoryX.fromId(widget.categoryId);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final trips = context.read<TripsProvider>();
    if (trips.trips.isEmpty) return;
    final defaultTrip = trips.upcomingTrips.isNotEmpty ? trips.upcomingTrips.first : trips.trips.first;
    setState(() => _selectedTripId = defaultTrip.id);
    if (widget.categoryId == ToolCategory.packing.id && _selectedTripId != null) {
      await context.read<TripToolsProvider>().ensurePackingDefaults(_selectedTripId!);
    }
  }

  String _label(BuildContext context) {
    return switch (category) {
      ToolCategory.flight => AppStrings.t(context, 'catFlight'),
      ToolCategory.hotel => AppStrings.t(context, 'catHotel'),
      ToolCategory.itinerary => AppStrings.t(context, 'catItinerary'),
      ToolCategory.packing => AppStrings.t(context, 'catPacking'),
      ToolCategory.expenses => AppStrings.t(context, 'catExpenses'),
      ToolCategory.documents => AppStrings.t(context, 'catDocuments'),
      ToolCategory.photos => AppStrings.t(context, 'catPhotos'),
      ToolCategory.notes => AppStrings.t(context, 'catNotes'),
      _ => widget.categoryId,
    };
  }

  String _emoji() {
    return switch (category) {
      ToolCategory.flight => '✈️',
      ToolCategory.hotel => '🏨',
      ToolCategory.itinerary => '🗺',
      ToolCategory.packing => '🎒',
      ToolCategory.expenses => '💰',
      ToolCategory.documents => '📄',
      ToolCategory.photos => '📸',
      ToolCategory.notes => '📝',
      _ => '🧳',
    };
  }

  @override
  Widget build(BuildContext context) {
    final trips = context.watch<TripsProvider>();
    final shop = context.watch<ShopProvider>();

    if (!CategoryAccess.isUnlocked(widget.categoryId, hasPremiumCategories: shop.hasPremiumCategories)) {
      return Scaffold(
        appBar: AppBar(title: Text('${_emoji()} ${_label(context)}')),
        body: TbEmptyState(
          message: AppStrings.t(context, 'categoryLocked'),
          actionLabel: AppStrings.t(context, 'unlock'),
          onAction: () {
            Navigator.pop(context);
            pushAppRoute(const ShopScreen(initialTab: ShopRewardsTab.features));
          },
        ),
      );
    }

    if (trips.trips.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('${_emoji()} ${_label(context)}')),
        body: TbEmptyState(
          message: AppStrings.t(context, 'needTripFirst'),
          actionLabel: AppStrings.t(context, 'createTrip'),
          onAction: () {
            Navigator.pop(context);
            CreateTripSheet.show();
          },
        ),
      );
    }

    _selectedTripId ??= trips.upcomingTrips.isNotEmpty ? trips.upcomingTrips.first.id : trips.trips.first.id;
    final trip = trips.trips.firstWhere((t) => t.id == _selectedTripId);
    final tools = context.watch<TripToolsProvider>();
    final items = tools.forTripCategory(trip.id, widget.categoryId);
    final showPhotoFab = category == ToolCategory.photos && items.isNotEmpty;
    final Widget? fab = switch (category) {
      ToolCategory.photos when showPhotoFab => FloatingActionButton.extended(
          onPressed: () => _uploadPhoto(trip.id),
          icon: const Icon(Icons.add_a_photo),
          label: Text(AppStrings.t(context, 'uploadPhoto')),
        ),
      ToolCategory.itinerary || ToolCategory.photos => null,
      _ => FloatingActionButton(
          onPressed: () => _addItem(trip.id),
          child: const Icon(Icons.add),
        ),
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${_emoji()} ${_label(context)}'),
        actions: [
          if (category == ToolCategory.itinerary)
            TextButton(
              onPressed: () {
                context.read<ShellProvider>().setIndex(3);
                Navigator.popUntil(context, (r) => r.isFirst);
              },
              child: Text(AppStrings.t(context, 'openItinerary')),
            ),
        ],
      ),
      floatingActionButton: fab,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TripSelector(
            trips: trips.trips,
            selectedId: _selectedTripId!,
            onChanged: (id) async {
              setState(() => _selectedTripId = id);
              if (widget.categoryId == ToolCategory.packing.id) {
                await context.read<TripToolsProvider>().ensurePackingDefaults(id);
              }
            },
          ),
          Expanded(child: _buildBody(trip, items)),
        ],
      ),
    );
  }

  Widget _buildBody(TripEntry trip, List<ToolEntry> items) {
    final tools = context.watch<TripToolsProvider>();

    if (category == ToolCategory.photos) {
      return _PhotosBody(
        items: items,
        onUpload: () => _uploadPhoto(trip.id),
        onDelete: (id) => tools.remove(id),
      );
    }

    if (category == ToolCategory.itinerary) {
      return _ItineraryBody(trip: trip, items: items, onAdd: () => _addItem(trip.id));
    }

    if (category == ToolCategory.expenses) {
      final total = tools.expenseTotal(trip.id);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              AppStrings.t(context, 'expenseTotal', {'amount': total.toStringAsFixed(0)}),
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? TbEmptyState(
                    message: AppStrings.t(context, 'toolEmptyHint'),
                    actionLabel: AppStrings.t(context, 'addItem'),
                    onAction: () => _addItem(trip.id),
                  )
                : _ToolList(
                    items: items,
                    isPacking: false,
                    onToggle: null,
                    onDelete: tools.remove,
                  ),
          ),
        ],
      );
    }

    if (category == ToolCategory.packing) {
      final done = items.where((e) => e.checked).length;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: LinearProgressIndicator(
              value: items.isEmpty ? 0 : done / items.length,
              backgroundColor: AppColors.border,
              color: AppColors.success,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              AppStrings.t(context, 'packingProgress', {'done': '$done', 'total': '${items.length}'}),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? TbEmptyState(
                    message: AppStrings.t(context, 'toolEmptyHint'),
                    actionLabel: AppStrings.t(context, 'addItem'),
                    onAction: () => _addItem(trip.id),
                  )
                : _ToolList(
                    items: items,
                    isPacking: true,
                    onToggle: (id) => tools.toggleChecked(id),
                    onDelete: tools.remove,
                  ),
          ),
        ],
      );
    }

    if (items.isEmpty) {
      return TbEmptyState(
        message: AppStrings.t(context, 'toolEmptyHint'),
        actionLabel: AppStrings.t(context, 'addItem'),
        onAction: () => _addItem(trip.id),
      );
    }

    return _ToolList(
      items: items,
      isPacking: false,
      onToggle: null,
      onDelete: tools.remove,
    );
  }

  Future<void> _uploadPhoto(String tripId) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(AppStrings.t(context, 'chooseFromGallery')),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(AppStrings.t(context, 'takePhoto')),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    final file = await _picker.pickImage(source: source, imageQuality: 85);
    if (file == null || !mounted) return;

    final dir = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${dir.path}/trip_photos');
    if (!await photosDir.exists()) await photosDir.create(recursive: true);
    final saved = File('${photosDir.path}/${const Uuid().v4()}.jpg');
    await File(file.path).copy(saved.path);

    await context.read<TripToolsProvider>().add(
          tripId: tripId,
          category: ToolCategory.photos.id,
          title: AppStrings.t(context, 'tripPhoto'),
          extra: saved.path,
        );
    if (mounted) AppToast.show(context, title: AppStrings.t(context, 'photoSaved'));
  }

  Future<void> _addItem(String tripId) async {
    final cat = category;
    if (cat == null) return;

    final titleCtrl = TextEditingController();
    final subCtrl = TextEditingController();
    final amountCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.t(context, 'addItem')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(labelText: _field1Label(context, cat)),
              ),
              if (cat != ToolCategory.notes) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: subCtrl,
                  decoration: InputDecoration(labelText: _field2Label(context, cat)),
                ),
              ],
              if (cat == ToolCategory.expenses) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: AppStrings.t(context, 'amount')),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.t(context, 'cancel'))),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(AppStrings.t(context, 'save'))),
        ],
      ),
    );

    if (ok != true || titleCtrl.text.trim().isEmpty || !mounted) return;

    await context.read<TripToolsProvider>().add(
          tripId: tripId,
          category: cat.id,
          title: titleCtrl.text.trim(),
          subtitle: subCtrl.text.trim(),
          amount: double.tryParse(amountCtrl.text.trim()) ?? 0,
        );
    if (mounted) AppToast.show(context, title: AppStrings.t(context, 'itemSaved'));
  }

  String _field1Label(BuildContext context, ToolCategory cat) {
    return switch (cat) {
      ToolCategory.flight => AppStrings.t(context, 'flightNumber'),
      ToolCategory.hotel => AppStrings.t(context, 'hotelName'),
      ToolCategory.itinerary => AppStrings.t(context, 'activityTitle'),
      ToolCategory.packing => AppStrings.t(context, 'itemName'),
      ToolCategory.expenses => AppStrings.t(context, 'expenseTitle'),
      ToolCategory.documents => AppStrings.t(context, 'documentName'),
      ToolCategory.notes => AppStrings.t(context, 'noteTitle'),
      _ => AppStrings.t(context, 'title'),
    };
  }

  String _field2Label(BuildContext context, ToolCategory cat) {
    return switch (cat) {
      ToolCategory.flight => AppStrings.t(context, 'flightRoute'),
      ToolCategory.hotel => AppStrings.t(context, 'hotelAddress'),
      ToolCategory.itinerary => AppStrings.t(context, 'activityTime'),
      ToolCategory.expenses => AppStrings.t(context, 'expenseCategory'),
      ToolCategory.documents => AppStrings.t(context, 'documentNote'),
      _ => AppStrings.t(context, 'details'),
    };
  }
}

class _TripSelector extends StatelessWidget {
  final List<TripEntry> trips;
  final String selectedId;
  final ValueChanged<String> onChanged;

  const _TripSelector({required this.trips, required this.selectedId, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedId,
          isExpanded: true,
          items: trips
              .map((t) => DropdownMenuItem(value: t.id, child: Text(t.title, overflow: TextOverflow.ellipsis)))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _ToolList extends StatelessWidget {
  final List<ToolEntry> items;
  final bool isPacking;
  final ValueChanged<String>? onToggle;
  final ValueChanged<String> onDelete;

  const _ToolList({
    required this.items,
    required this.isPacking,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final item = items[i];
        return Dismissible(
          key: ValueKey(item.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => onDelete(item.id),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.delete_outline, color: AppColors.error),
          ),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: AppColors.border),
              ),
              leading: isPacking
                  ? Checkbox(
                      value: item.checked,
                      onChanged: (_) => onToggle?.call(item.id),
                      activeColor: AppColors.primary,
                    )
                  : CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Icon(_iconFor(item.category), color: AppColors.primary, size: 20),
                    ),
              title: Text(
                item.title,
                style: TextStyle(
                  decoration: isPacking && item.checked ? TextDecoration.lineThrough : null,
                  color: isPacking && item.checked ? AppColors.textMuted : AppColors.textPrimary,
                ),
              ),
              subtitle: item.subtitle.isNotEmpty
                  ? Text(item.subtitle, style: const TextStyle(fontSize: 12))
                  : item.amount > 0
                      ? Text('${item.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.coin))
                      : null,
            ),
          ),
        );
      },
    );
  }

  IconData _iconFor(String category) {
    return switch (category) {
      'flight' => Icons.flight,
      'hotel' => Icons.hotel,
      'itinerary' => Icons.map,
      'expenses' => Icons.payments,
      'documents' => Icons.description,
      'notes' => Icons.note,
      _ => Icons.luggage,
    };
  }
}

class _PhotosBody extends StatelessWidget {
  final List<ToolEntry> items;
  final VoidCallback onUpload;
  final ValueChanged<String> onDelete;

  const _PhotosBody({required this.items, required this.onUpload, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return TbEmptyState(
        message: AppStrings.t(context, 'photoUploadHint'),
        actionLabel: AppStrings.t(context, 'uploadPhoto'),
        actionIcon: Icons.add_a_photo_outlined,
        onAction: onUpload,
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        final file = File(item.extra);
        return GestureDetector(
          onLongPress: () => onDelete(item.id),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: file.existsSync()
                ? Image.file(file, fit: BoxFit.cover)
                : Container(
                    color: AppColors.headerBlue,
                    child: const Icon(Icons.broken_image, color: AppColors.textMuted),
                  ),
          ),
        );
      },
    );
  }
}

class _ItineraryBody extends StatelessWidget {
  final TripEntry trip;
  final List<ToolEntry> items;
  final VoidCallback onAdd;

  const _ItineraryBody({required this.trip, required this.items, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(trip.title, style: AppTypography.titleLarge().copyWith(fontSize: 18)),
              const SizedBox(height: 4),
              Text('${trip.destination} · ${trip.dateRange}', style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Text('${trip.dayCount} days · ${trip.hotelCount} hotels · ${trip.destinationCount} places'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (items.isEmpty)
          TbEmptyState(
            message: AppStrings.t(context, 'itineraryAddHint'),
            actionLabel: AppStrings.t(context, 'addActivity'),
            onAction: onAdd,
          )
        else
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppColors.border)),
                  leading: const CircleAvatar(child: Icon(Icons.place, size: 20)),
                  title: Text(item.title),
                  subtitle: item.subtitle.isNotEmpty ? Text(item.subtitle) : null,
                ),
              )),
      ],
    );
  }
}
