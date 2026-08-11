import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/navigation/app_navigator.dart';
import '../../models/trip.dart';
import '../../providers/shop_provider.dart';
import '../../providers/shell_provider.dart';
import '../../providers/trips_provider.dart';
import '../../screens/shop/shop_screen.dart';
import '../../widgets/app_ui.dart';
import '../../widgets/coin_balance_chip.dart';
import '../../widgets/trip_design.dart';
import '../trips/create_trip_sheet.dart';
import '../trips/trip_detail_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openTrip(BuildContext context, TripEntry trip) {
    context.read<TripsProvider>().markViewed(trip.id);
    TripDetailSheet.show(trip);
  }

  void _openItinerary(BuildContext context) {
    context.read<ShellProvider>().setIndex(3);
  }

  void _openExplore(BuildContext context) {
    context.read<ShellProvider>().setIndex(1);
  }

  String _firstName(String fullName) {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return 'Traveler';
    return trimmed.split(RegExp(r'\s+')).first;
  }

  @override
  Widget build(BuildContext context) {
    final trips = context.watch<TripsProvider>();
    final shop = context.watch<ShopProvider>();
    final nextTrip = trips.nextUpcomingTrip;
    final recent = trips.recentlyViewed;
    final firstName = _firstName(trips.profileName);

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: _HomeHero(
                firstName: firstName,
                profileInitial: trips.profileName.trim().isNotEmpty ? trips.profileName.trim()[0].toUpperCase() : 'T',
                upcomingCount: trips.upcomingTrips.length,
                tripCount: trips.tripCount,
                tripMax: trips.tripLimit(shop.hasUnlimitedTrips),
                hasUnlimitedTrips: shop.hasUnlimitedTrips,
                coins: shop.coins,
                onCreateTrip: () => CreateTripSheet.show(),
                onExplore: () => _openExplore(context),
                onItinerary: () => _openItinerary(context),
                onShop: () => pushAppRoute(const ShopScreen()),
              ),
            ),
          ),
          if (nextTrip != null) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppStrings.t(context, 'homeNextTrip'),
                        style: AppTypography.titleLarge().copyWith(fontSize: 16),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _openItinerary(context),
                      child: Text(AppStrings.t(context, 'homeViewAllTrips')),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TbTripCard(
                  title: nextTrip.title,
                  subtitle: nextTrip.destination,
                  imageUrl: nextTrip.imageUrl,
                  dateRange: nextTrip.dateRange,
                  members: nextTrip.members,
                  onTap: () => _openTrip(context, nextTrip),
                ),
              ),
            ),
          ] else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                child: TbEmptyState(
                  message: AppStrings.t(context, 'homeCreateFirst'),
                  actionLabel: AppStrings.t(context, 'createTrip'),
                  onAction: () => CreateTripSheet.show(),
                ),
              ),
            ),
          if (recent.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Text(
                  AppStrings.t(context, 'recentlyViewed'),
                  style: AppTypography.titleLarge().copyWith(fontSize: 16),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  primary: false,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: recent.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) {
                    final t = recent[i];
                    return TbTripCard(
                      compact: true,
                      title: t.title,
                      subtitle: t.destination,
                      imageUrl: t.imageUrl,
                      hotelCount: t.hotelCount,
                      destinationCount: t.destinationCount,
                      onTap: () => _openTrip(context, t),
                    );
                  },
                ),
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 96)),
        ],
      ),
    );
  }
}

class _HomeHero extends StatelessWidget {
  final String firstName;
  final String profileInitial;
  final int upcomingCount;
  final int tripCount;
  final int tripMax;
  final bool hasUnlimitedTrips;
  final int coins;
  final VoidCallback onCreateTrip;
  final VoidCallback onExplore;
  final VoidCallback onItinerary;
  final VoidCallback onShop;

  const _HomeHero({
    required this.firstName,
    required this.profileInitial,
    required this.upcomingCount,
    required this.tripCount,
    required this.tripMax,
    required this.hasUnlimitedTrips,
    required this.coins,
    required this.onCreateTrip,
    required this.onExplore,
    required this.onItinerary,
    required this.onShop,
  });

  @override
  Widget build(BuildContext context) {
    final tripProgress = hasUnlimitedTrips ? 0.0 : (tripCount / tripMax).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.22),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                profileInitial,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.t(context, 'homeGreeting', {'name': firstName}),
                    style: AppTypography.titleLarge().copyWith(fontSize: 18, height: 1.1),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppStrings.t(context, 'appTagline'),
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.2),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            CoinBalanceChip(variant: CoinChipVariant.header, onTap: onShop),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatBlock(
                        value: '$upcomingCount',
                        label: AppStrings.t(context, 'homeUpcomingLabel'),
                      ),
                    ),
                    Container(width: 1, height: 36, color: AppColors.border),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasUnlimitedTrips
                                  ? AppStrings.t(context, 'shopFeatUnlimitedTrips')
                                  : AppStrings.t(context, 'tripLimitHint', {
                                      'current': '$tripCount',
                                      'max': '$tripMax',
                                    }),
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(99),
                              child: LinearProgressIndicator(
                                value: hasUnlimitedTrips ? null : tripProgress,
                                minHeight: 5,
                                backgroundColor: AppColors.primarySoft,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: AppColors.border.withValues(alpha: 0.8)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: Row(
                  children: [
                    _QuickAction(
                      icon: Icons.add_rounded,
                      label: AppStrings.t(context, 'createTrip'),
                      onTap: onCreateTrip,
                      filled: true,
                    ),
                    _QuickAction(
                      icon: Icons.explore_rounded,
                      label: AppStrings.t(context, 'homeOpenExplore'),
                      onTap: onExplore,
                    ),
                    _QuickAction(
                      icon: Icons.luggage_rounded,
                      label: AppStrings.t(context, 'homeOpenItinerary'),
                      onTap: onItinerary,
                    ),
                    _QuickAction(
                      icon: Icons.star_rounded,
                      label: AppStrings.t(context, 'shop'),
                      onTap: onShop,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String value;
  final String label;

  const _StatBlock({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTypography.titleLarge().copyWith(fontSize: 22, color: AppColors.primary, height: 1),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool filled;

  const _QuickAction({
    required this.icon,
    required this.label,
    this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: filled ? AppColors.primaryGradient : null,
                    color: filled ? null : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: filled ? null : Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                  ),
                  child: Icon(icon, color: filled ? Colors.white : AppColors.primary, size: 20),
                ),
                const SizedBox(height: 5),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: filled ? FontWeight.w600 : FontWeight.w500,
                    color: filled ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
