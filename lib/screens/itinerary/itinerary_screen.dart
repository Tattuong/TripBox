import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../models/trip.dart';
import '../../providers/trips_provider.dart';
import '../../widgets/app_ui.dart';
import '../../widgets/trip_design.dart';
import '../trips/create_trip_sheet.dart';
import '../trips/trip_detail_sheet.dart';

class ItineraryScreen extends StatefulWidget {
  const ItineraryScreen({super.key});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  int _tab = 0;

  void _openTrip(TripEntry trip) {
    context.read<TripsProvider>().markViewed(trip.id);
    TripDetailSheet.show(trip);
  }

  @override
  Widget build(BuildContext context) {
    final trips = context.watch<TripsProvider>();
    final list = _tab == 0 ? trips.allTrips : trips.upcomingTrips;

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(AppStrings.t(context, 'itinerary'), style: AppTypography.titleLarge().copyWith(fontSize: 28)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  TbFilterChip(
                    label: AppStrings.t(context, 'allTrip'),
                    selected: _tab == 0,
                    onTap: () => setState(() => _tab = 0),
                  ),
                  TbFilterChip(
                    label: AppStrings.t(context, 'upcomingItinerary'),
                    selected: _tab == 1,
                    onTap: () => setState(() => _tab = 1),
                  ),
                ],
              ),
            ),
          ),
          if (list.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: TbEmptyState(
                  message: AppStrings.t(context, 'noTripsHint'),
                  actionLabel: AppStrings.t(context, 'createTrip'),
                  onAction: () => CreateTripSheet.show(),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              sliver: SliverList.separated(
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, i) {
                  final t = list[i];
                  return TbTripCard(
                    title: t.title,
                    subtitle: t.destination,
                    imageUrl: t.imageUrl,
                    dateRange: t.dateRange,
                    members: t.members,
                    onTap: () => _openTrip(t),
                  );
                },
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 96)),
        ],
      ),
    );
  }
}
