import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../constants/app_strings.dart';

class CoverPhotoPicker {
  CoverPhotoPicker._();

  static final _picker = ImagePicker();
  static const _uuid = Uuid();

  static Future<String?> pick(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(AppStrings.t(context, 'chooseFromGallery')),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text(AppStrings.t(context, 'takePhoto')),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return null;

    final file = await _picker.pickImage(source: source, imageQuality: 85, maxWidth: 1920);
    if (file == null) return null;

    final dir = await getApplicationDocumentsDirectory();
    final coversDir = Directory('${dir.path}/trip_covers');
    if (!await coversDir.exists()) await coversDir.create(recursive: true);
    final saved = File('${coversDir.path}/${_uuid.v4()}.jpg');
    await File(file.path).copy(saved.path);
    return saved.path;
  }
}

class TripCoverImage extends StatelessWidget {
  final String url;
  final BoxFit fit;

  const TripCoverImage({super.key, required this.url, this.fit = BoxFit.cover});

  static bool isLocalPath(String url) =>
      url.startsWith('/') || url.startsWith('file://');

  static Widget placeholder({double iconSize = 48}) {
    return ColoredBox(
      color: const Color(0xFFE8F4FD),
      child: Center(
        child: Icon(Icons.landscape_outlined, size: iconSize, color: const Color(0xFF1E56A0)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return placeholder();

    if (isLocalPath(url)) {
      final path = url.startsWith('file://') ? url.substring(7) : url;
      final file = File(path);
      if (!file.existsSync()) return placeholder();
      return ColoredBox(
        color: const Color(0xFFE8F4FD),
        child: Image.file(file, fit: fit, width: double.infinity, height: double.infinity),
      );
    }

    return ColoredBox(
      color: const Color(0xFFE8F4FD),
      child: Image.network(
        url,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => placeholder(),
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1E56A0)),
          );
        },
      ),
    );
  }
}
