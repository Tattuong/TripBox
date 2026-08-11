import 'package:flutter/material.dart';

class AppColors {
  // Primary — medium ocean blue (mockup #1E56A0)
  static const Color primary = Color(0xFF1E56A0);
  static const Color primaryLight = Color(0xFF4A90D9);
  static const Color primarySoft = Color(0xFFE8F4FD);
  static const Color primaryMuted = Color(0xFFB8D4F0);

  static const Color accent = Color(0xFF5B9BD5);
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFFB020);
  static const Color error = Color(0xFFFF3B30);
  static const Color coin = Color(0xFFFFB020);

  static const Color background = Color(0xFFF7FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F4F8);
  static const Color border = Color(0xFFE8EDF2);

  static const Color textPrimary = Color(0xFF1A2332);
  static const Color textSecondary = Color(0xFF5A6578);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = textPrimary;
  static const Color onSurfaceVariant = textSecondary;

  // Bottom nav — clean white bar, blue accent
  static const Color navBar = Color(0xFFFFFFFF);
  static const Color navActive = Color(0xFF1E56A0);
  static const Color navInactive = Color(0xFF94A3B8);
  static const Color headerBlue = Color(0xFFE8F4FD);

  static const Color darkBackground = Color(0xFF0F1419);
  static const Color darkSurface = Color(0xFF1A2332);
  static const Color darkCard = Color(0xFF243044);
  static const Color trueBlack = Color(0xFF0A0A0A);

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFD6EBFF), Color(0xFFF0F7FF), Color(0xFFFFFFFF)],
    stops: [0.0, 0.45, 1.0],
  );

  static const LinearGradient accountHeaderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD6EBFF), Color(0xFFEEF6FF), Color(0xFFFFFFFF)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFD6EBFF), Color(0xFFF7FAFC)],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4A90D9), Color(0xFF1E56A0)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4A90D9), Color(0xFF1E56A0)],
  );

  static const LinearGradient shopPromoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEEF6FF), Color(0xFFD6EBFF)],
  );

  static const LinearGradient vipGoldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF4D6), Color(0xFFFFB020), Color(0xFFE69500)],
  );

  static const LinearGradient shopVipHeroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E56A0), Color(0xFF163D72), Color(0xFF0F2847)],
  );

  // Category pastels (mockup style)
  static const catFlightBg = Color(0xFFFFF0E6);
  static const catFlightFg = Color(0xFFE8752A);
  static const catHotelBg = Color(0xFFE6F4FF);
  static const catHotelFg = Color(0xFF1E56A0);
  static const catItineraryBg = Color(0xFFF0EAFF);
  static const catItineraryFg = Color(0xFF7C5CBF);
  static const catPackingBg = Color(0xFFE8FAF0);
  static const catPackingFg = Color(0xFF2EAD6D);
  static const catExpensesBg = Color(0xFFFFF8E6);
  static const catExpensesFg = Color(0xFFD4A017);
  static const catDocumentsBg = Color(0xFFF5F5F0);
  static const catDocumentsFg = Color(0xFF6B7280);
  static const catPhotosBg = Color(0xFFFFEEF5);
  static const catPhotosFg = Color(0xFFE85D9A);
  static const catNotesBg = Color(0xFFEDF0FF);
  static const catNotesFg = Color(0xFF5B6FD8);
}
