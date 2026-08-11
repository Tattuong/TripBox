import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/navigation/app_navigator.dart';
import '../../core/utils/cover_photo_picker.dart';
import '../../models/trip_tool_data.dart';
import '../../providers/trip_tools_provider.dart';
import '../../providers/trips_provider.dart';
import '../../widgets/trip_design.dart';
import '../tools/category_tool_screen.dart';

class MomentsScreen extends StatelessWidget {
  const MomentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = context.watch<TripToolsProvider>();
    final trips = context.watch<TripsProvider>();
    final photos = tools.allPhotos;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.t(context, 'moment')),
      ),
      body: photos.isEmpty
          ? TbEmptyState(
              message: AppStrings.t(context, 'momentsEmpty'),
              actionLabel: AppStrings.t(context, 'uploadPhoto'),
              actionIcon: Icons.add_a_photo_outlined,
              onAction: () {
                if (trips.trips.isEmpty) {
                  Navigator.pop(context);
                  return;
                }
                pushAppRoute(const CategoryToolScreen(categoryId: 'photos'));
              },
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.82,
              ),
              itemCount: photos.length,
              itemBuilder: (_, i) {
                final entry = photos[i];
                final trip = trips.tripById(entry.tripId);
                return _MomentTile(
                  entry: entry,
                  tripTitle: trip?.title ?? entry.title,
                );
              },
            ),
    );
  }
}

class _MomentTile extends StatelessWidget {
  final ToolEntry entry;
  final String tripTitle;

  const _MomentTile({required this.entry, required this.tripTitle});

  @override
  Widget build(BuildContext context) {
    final file = File(entry.extra);

    return GestureDetector(
      onTap: () => _openPreview(context, file),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            file.existsSync()
                ? Image.file(file, fit: BoxFit.cover)
                : TripCoverImage.placeholder(iconSize: 36),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
                  ),
                ),
                child: Text(
                  tripTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openPreview(BuildContext context, File file) {
    if (!file.existsSync()) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            InteractiveViewer(
              child: Image.file(file, fit: BoxFit.contain),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                onPressed: () => Navigator.pop(ctx),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
