import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/iap_constants.dart';
import '../../core/navigation/app_navigator.dart';
import '../../core/utils/cover_photo_picker.dart';
import '../../providers/shop_provider.dart';
import '../../providers/trips_provider.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/trip_design.dart';

class CreateTripSheet {
  static Future<void> show() async {
    await showAppModal(const _CreateTripSheet());
  }
}

class _CreateTripSheet extends StatefulWidget {
  const _CreateTripSheet();

  @override
  State<_CreateTripSheet> createState() => _CreateTripSheetState();
}

class _CreateTripSheetState extends State<_CreateTripSheet> {
  final _titleCtrl = TextEditingController();
  final _destCtrl = TextEditingController();
  DateTime _start = DateTime.now().add(const Duration(days: 7));
  DateTime _end = DateTime.now().add(const Duration(days: 14));
  String? _coverPath;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _destCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _start : _end,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _start = picked;
          if (_end.isBefore(_start)) _end = _start.add(const Duration(days: 1));
        } else {
          _end = picked;
        }
      });
    }
  }

  Future<void> _pickCover() async {
    final path = await CoverPhotoPicker.pick(context);
    if (path != null && mounted) setState(() => _coverPath = path);
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    final dest = _destCtrl.text.trim();
    if (title.isEmpty || dest.isEmpty) {
      AppToast.show(context, title: AppStrings.t(context, 'tripEmptyFields'));
      return;
    }

    final trips = context.read<TripsProvider>();
    final shop = context.read<ShopProvider>();
    final ok = await trips.addTrip(
      title: title,
      destination: dest,
      startDate: _start,
      endDate: _end,
      imageUrl: _coverPath ?? '',
      hasPremium: shop.hasUnlimitedTrips,
    );

    if (!mounted) return;
    if (ok) {
      await shop.rewardForTripCreated();
      AppToast.show(context, title: AppStrings.t(context, 'tripCreated'));
      Navigator.pop(context);
    } else {
      AppToast.show(context, title: AppStrings.t(context, 'tripLimitReached'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final trips = context.watch<TripsProvider>();
    final shop = context.watch<ShopProvider>();
    final limit = trips.tripLimit(shop.hasUnlimitedTrips);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TbSheetHandle(),
              Text(AppStrings.t(context, 'createTrip'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              if (!shop.hasUnlimitedTrips) ...[
                const SizedBox(height: 6),
                Text(
                  AppStrings.t(context, 'tripLimitHint', {
                    'current': '${trips.tripCount}',
                    'max': '${IapConstants.freeTripLimit}',
                  }),
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickCover,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    height: 140,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        TripCoverImage(url: _coverPath ?? ''),
                        Container(
                          color: Colors.black.withValues(alpha: 0.25),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.add_a_photo_outlined, color: Colors.white, size: 28),
                                const SizedBox(height: 6),
                                Text(
                                  AppStrings.t(context, 'changeCoverPhoto'),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  labelText: AppStrings.t(context, 'tripTitle'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _destCtrl,
                decoration: InputDecoration(
                  labelText: AppStrings.t(context, 'destination'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickDate(true),
                      child: Text('${AppStrings.t(context, 'startDate')}: ${_start.day}/${_start.month}'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickDate(false),
                      child: Text('${AppStrings.t(context, 'endDate')}: ${_end.day}/${_end.month}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: trips.tripCount >= limit && !shop.hasUnlimitedTrips ? null : _save,
                child: Text(AppStrings.t(context, 'save')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
