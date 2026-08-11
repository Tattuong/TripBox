import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/trip.dart';
import '../../providers/trips_provider.dart';
import '../../widgets/trip_design.dart';
import '../trips/trip_detail_sheet.dart';

class SearchScreen extends StatefulWidget {
  final String? initialCategory;

  const SearchScreen({super.key, this.initialCategory});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _queryCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _query = widget.initialCategory!;
      _queryCtrl.text = _query;
    }
  }

  @override
  void dispose() {
    _queryCtrl.dispose();
    super.dispose();
  }

  void _openTrip(TripEntry trip) {
    context.read<TripsProvider>().markViewed(trip.id);
    TripDetailSheet.show(trip);
  }

  @override
  Widget build(BuildContext context) {
    final trips = context.watch<TripsProvider>();
    final results = trips.search(_query);

    return Scaffold(
      body: TbBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    ),
                    Expanded(
                      child: TbSearchBar(
                        hint: AppStrings.t(context, 'searchDestination'),
                        onChanged: (v) => setState(() => _query = v),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: results.isEmpty
                    ? Center(
                        child: Text(
                          _query.isEmpty ? AppStrings.t(context, 'searchDestination') : AppStrings.t(context, 'noTrips'),
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: results.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final t = results[i];
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
            ],
          ),
        ),
      ),
    );
  }
}
