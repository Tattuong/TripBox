import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/shell_provider.dart';
import 'account/account_screen.dart';
import 'explore/explore_screen.dart';
import 'home/home_screen.dart';
import 'itinerary/itinerary_screen.dart';
import 'trips/create_trip_sheet.dart';
import '../widgets/trip_design.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  void _openCreateTrip() => CreateTripSheet.show();

  @override
  Widget build(BuildContext context) {
    final index = context.watch<ShellProvider>().currentIndex;

    return TbScaffold(
      body: IndexedStack(
        index: _navIndex(index),
        children: const [
          HomeScreen(),
          ExploreScreen(),
          ItineraryScreen(),
          AccountScreen(),
        ],
      ),
      bottomNavigationBar: TbBottomNav(
        index: index,
        onTap: (i) {
          if (i == 2) {
            _openCreateTrip();
          } else {
            context.read<ShellProvider>().setIndex(i);
          }
        },
        onCreateTap: _openCreateTrip,
      ),
    );
  }

  int _navIndex(int tab) {
    if (tab <= 1) return tab;
    if (tab == 3) return 2;
    if (tab == 4) return 3;
    return 1;
  }
}
