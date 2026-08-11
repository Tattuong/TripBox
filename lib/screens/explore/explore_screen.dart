import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/navigation/app_navigator.dart';
import '../../core/utils/category_access.dart';
import '../../models/trip.dart';
import '../../providers/shop_provider.dart';
import '../../providers/trips_provider.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/app_ui.dart';
import '../../widgets/trip_design.dart';
import '../search/search_screen.dart';
import '../shop/shop_screen.dart';
import '../tools/category_tool_screen.dart';
import '../trips/create_trip_sheet.dart';
import '../trips/trip_detail_sheet.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  void _openTrip(BuildContext context, TripEntry trip) {
    context.read<TripsProvider>().markViewed(trip.id);
    TripDetailSheet.show(trip);
  }

  void _openCategory(BuildContext context, String categoryId) {
    final shop = context.read<ShopProvider>();
    if (!CategoryAccess.isUnlocked(categoryId, hasPremiumCategories: shop.hasPremiumCategories)) {
      AppToast.show(context, title: AppStrings.t(context, 'categoryLocked'));
      pushAppRoute(const ShopScreen(initialTab: ShopRewardsTab.features));
      return;
    }
    pushAppRoute(CategoryToolScreen(categoryId: categoryId));
  }

  @override
  Widget build(BuildContext context) {
    final trips = context.watch<TripsProvider>();
    final shop = context.watch<ShopProvider>();
    final recent = trips.recentlyViewed;

    final categories = TravelCategories.all
        .map((c) => TravelCategoryItem(
              id: c.id,
              label: AppStrings.t(context, c.labelKey),
              emoji: c.emoji,
              icon: c.icon,
              color: c.color,
              bgColor: c.bgColor,
              locked: !CategoryAccess.isUnlocked(c.id, hasPremiumCategories: shop.hasPremiumCategories),
            ))
        .toList();

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(gradient: AppColors.headerGradient),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.t(context, 'explore'), style: AppTypography.titleLarge().copyWith(fontSize: 24)),
                  const SizedBox(height: 2),
                  Text(AppStrings.t(context, 'exploreToolsHint'), style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 10),
                  TbSearchBar(
                    hint: AppStrings.t(context, 'searchDestination'),
                    readOnly: true,
                    onTap: () => pushAppRoute(const SearchScreen()),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(AppStrings.t(context, 'travelTools'), style: AppTypography.titleLarge().copyWith(fontSize: 16)),
                      ),
                      if (!shop.hasPremiumCategories)
                        Text(
                          AppStrings.t(context, 'freeCategoriesHint', {'count': '${CategoryAccess.freeCategoryIds.length}'}),
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TbCategoryGrid(
                    categories: categories,
                    onCategoryTap: (id) => _openCategory(context, id),
                  ),
                ],
              ),
            ),
          ),
          if (recent.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Text(AppStrings.t(context, 'recentlyViewed'), style: AppTypography.titleLarge().copyWith(fontSize: 16)),
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
          ] else if (trips.trips.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: TbEmptyState(
                  message: AppStrings.t(context, 'exploreEmptyHint'),
                  actionLabel: AppStrings.t(context, 'createTrip'),
                  onAction: () => CreateTripSheet.show(),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 96)),
        ],
      ),
    );
  }
}
