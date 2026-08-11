import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/cover_photo_picker.dart';
import '../../models/trip.dart';
import '../../providers/trips_provider.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/app_ui.dart';
import '../../widgets/trip_design.dart';
import '../trips/trip_detail_sheet.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trips = context.watch<TripsProvider>();
    final list = trips.wishlistTrips;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.t(context, 'wishlist')),
      ),
      body: list.isEmpty
          ? TbEmptyState(
              message: AppStrings.t(context, 'wishlistEmpty'),
              actionLabel: AppStrings.t(context, 'openItinerary'),
              onAction: () => Navigator.pop(context),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final trip = list[i];
                return _WishlistTile(
                  trip: trip,
                  onOpen: () => TripDetailSheet.show(trip),
                  onRemove: () async {
                    await context.read<TripsProvider>().toggleWishlist(trip.id);
                    if (context.mounted) {
                      AppToast.show(context, title: AppStrings.t(context, 'removedFromWishlist'));
                    }
                  },
                );
              },
            ),
    );
  }
}

class _WishlistTile extends StatelessWidget {
  final TripEntry trip;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  const _WishlistTile({required this.trip, required this.onOpen, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                child: SizedBox(
                  width: 88,
                  height: 88,
                  child: TripCoverImage(url: trip.imageUrl),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(trip.title, style: AppTypography.titleLarge().copyWith(fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(trip.destination, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(trip.dateRange, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.favorite, color: AppColors.error),
                tooltip: AppStrings.t(context, 'removeFromWishlist'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
