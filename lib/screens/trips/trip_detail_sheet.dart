import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/navigation/app_navigator.dart';
import '../../core/utils/cover_photo_picker.dart';
import '../../core/utils/trip_weather.dart';
import '../../models/trip.dart';
import '../../models/trip_member.dart';
import '../../providers/shop_provider.dart';
import '../../providers/trips_provider.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/trip_design.dart';
import '../shop/shop_screen.dart';
import 'invite_friend_sheet.dart';

class TripDetailSheet {
  static Future<void> show(TripEntry trip) async {
    await showAppModal(_TripDetailSheet(tripId: trip.id));
  }
}

class _TripDetailSheet extends StatelessWidget {
  final String tripId;

  const _TripDetailSheet({required this.tripId});

  Future<void> _changeCover(BuildContext context, TripEntry trip) async {
    final path = await CoverPhotoPicker.pick(context);
    if (path == null || !context.mounted) return;
    await context.read<TripsProvider>().updateTripCover(trip.id, path);
    if (context.mounted) AppToast.show(context, title: AppStrings.t(context, 'coverPhotoUpdated'));
  }

  Future<void> _exportTrip(BuildContext context, TripEntry trip) async {
    final shop = context.read<ShopProvider>();
    if (!shop.hasExport) {
      AppToast.show(context, title: AppStrings.t(context, 'exportLocked'));
      pushAppRoute(const ShopScreen(initialTab: ShopRewardsTab.features));
      return;
    }
    final members = trip.members.map((m) => m.name).join(', ');
    final text = '${trip.title}\n${trip.destination}\n${trip.dateRange}\n${trip.dayCount} days\nTravelers: $members';
    await Share.share(text, subject: trip.title);
  }

  Future<void> _deleteTrip(BuildContext context, TripEntry trip) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.t(context, 'delete')),
        content: Text('${AppStrings.t(context, 'delete')} "${trip.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.t(context, 'cancel'))),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(AppStrings.t(context, 'delete'))),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<TripsProvider>().deleteTrip(trip.id);
    if (context.mounted) {
      AppToast.show(context, title: AppStrings.t(context, 'tripDeleted'));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = context.watch<TripsProvider>().tripById(tripId);
    final shop = context.watch<ShopProvider>();
    if (trip == null) return const SizedBox.shrink();

    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final weather = TripWeather.forDestination(trip.destination);

    return Container(
      padding: EdgeInsets.only(bottom: bottom),
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.9),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TbSheetHandle(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => _changeCover(context, trip),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          height: 160,
                          width: double.infinity,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              TbTripImage(url: trip.imageUrl),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: _WishlistButton(tripId: trip.id),
                              ),
                              Positioned(
                                right: 10,
                                bottom: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.55),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.photo_camera_outlined, color: Colors.white, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        AppStrings.t(context, 'changeCoverPhoto'),
                                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
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
                    Text(trip.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(trip.destination, style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                    const SizedBox(height: 12),
                    _InfoRow(icon: Icons.date_range, label: trip.dateRange),
                    _InfoRow(icon: Icons.timelapse, label: '${trip.dayCount} days'),
                    if (trip.hotelCount > 0) _InfoRow(icon: Icons.hotel, label: '${trip.hotelCount} hotels'),
                    if (trip.destinationCount > 0)
                      _InfoRow(icon: Icons.place, label: '${trip.destinationCount} destinations'),
                    const SizedBox(height: 12),
                    _OfflineBadge(hasOffline: shop.hasOffline),
                    if (shop.hasWeather) ...[
                      const SizedBox(height: 12),
                      _WeatherCard(destination: trip.destination, weather: weather),
                    ] else
                      _LockedFeatureHint(
                        icon: Icons.wb_sunny_outlined,
                        message: AppStrings.t(context, 'weatherLocked'),
                        onUnlock: () => pushAppRoute(const ShopScreen(initialTab: ShopRewardsTab.features)),
                      ),
                    const SizedBox(height: 20),
                    _MembersSection(trip: trip, canInvite: shop.hasShare),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _exportTrip(context, trip),
                            icon: Icon(Icons.upload_outlined, size: 18, color: shop.hasExport ? null : AppColors.textMuted),
                            label: Text(AppStrings.t(context, 'exportTrip')),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => _deleteTrip(context, trip),
                            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: Text(AppStrings.t(context, 'delete')),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WishlistButton extends StatelessWidget {
  final String tripId;

  const _WishlistButton({required this.tripId});

  @override
  Widget build(BuildContext context) {
    final trips = context.watch<TripsProvider>();
    final saved = trips.isWishlisted(tripId);

    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: () async {
          final nowSaved = await context.read<TripsProvider>().toggleWishlist(tripId);
          if (context.mounted) {
            AppToast.show(
              context,
              title: AppStrings.t(context, nowSaved ? 'addedToWishlist' : 'removedFromWishlist'),
            );
          }
        },
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            saved ? Icons.favorite : Icons.favorite_border,
            color: saved ? AppColors.error : Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _OfflineBadge extends StatelessWidget {
  final bool hasOffline;

  const _OfflineBadge({required this.hasOffline});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: hasOffline ? AppColors.success.withValues(alpha: 0.08) : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: hasOffline ? AppColors.success.withValues(alpha: 0.25) : AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            hasOffline ? Icons.offline_pin_rounded : Icons.cloud_off_outlined,
            size: 18,
            color: hasOffline ? AppColors.success : AppColors.textMuted,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              hasOffline ? AppStrings.t(context, 'offlineEnabled') : AppStrings.t(context, 'offlineLocked'),
              style: TextStyle(
                fontSize: 13,
                color: hasOffline ? AppColors.success : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (!hasOffline)
            TextButton(
              onPressed: () => pushAppRoute(const ShopScreen(initialTab: ShopRewardsTab.features)),
              child: Text(AppStrings.t(context, 'unlock'), style: const TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  final String destination;
  final TripWeatherInfo weather;

  const _WeatherCard({required this.destination, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.t(context, 'weatherFor', {'place': destination.split(',').first.trim()}),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  '${weather.celsius}°C · ${weather.condition}',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedFeatureHint extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback onUnlock;

  const _LockedFeatureHint({required this.icon, required this.message, required this.onUnlock});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textMuted),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
            TextButton(onPressed: onUnlock, child: Text(AppStrings.t(context, 'unlock'), style: const TextStyle(fontSize: 12))),
          ],
        ),
      ),
    );
  }
}

class _MembersSection extends StatelessWidget {
  final TripEntry trip;
  final bool canInvite;

  const _MembersSection({required this.trip, required this.canInvite});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                AppStrings.t(context, 'travelCompanions'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            TextButton.icon(
              onPressed: canInvite
                  ? () => InviteFriendSheet.show(trip)
                  : () {
                      AppToast.show(context, title: AppStrings.t(context, 'shareLocked'));
                      pushAppRoute(const ShopScreen(initialTab: ShopRewardsTab.features));
                    },
              icon: Icon(Icons.person_add_outlined, size: 18, color: canInvite ? null : AppColors.textMuted),
              label: Text(AppStrings.t(context, 'inviteFriend')),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: trip.members.map((m) => _MemberChip(member: m)).toList(),
        ),
      ],
    );
  }
}

class _MemberChip extends StatelessWidget {
  final TripMember member;

  const _MemberChip({required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.primary,
            child: Text(
              member.initial,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
          Text(member.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          if (member.isOwner) ...[
            const SizedBox(width: 4),
            Text(
              '(${AppStrings.t(context, 'you')})',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
