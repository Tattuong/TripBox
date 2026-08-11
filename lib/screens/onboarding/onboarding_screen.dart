import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/trips_provider.dart';
import '../../widgets/app_ui.dart';
import '../main_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _page = 0;

  static const _pages = [
    ('onboardTitle1', 'onboardDesc1', Icons.flight_takeoff_rounded),
    ('onboardTitle2', 'onboardDesc2', Icons.explore_rounded),
    ('onboardTitle3', 'onboardDesc3', Icons.star_rounded),
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await context.read<TripsProvider>().completeOnboarding();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainShell()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(AppStrings.t(context, 'skip')),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: _pages.length,
                onPageChanged: (p) => setState(() => _page = p),
                itemBuilder: (_, i) {
                  final (titleKey, descKey, icon) = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, size: 64, color: AppColors.primary),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          AppStrings.t(context, titleKey),
                          textAlign: TextAlign.center,
                          style: AppTypography.titleLarge().copyWith(fontSize: 24),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppStrings.t(context, descKey),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.5),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _page == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _page == i ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: FilledButton(
                onPressed: () {
                  if (_page < _pages.length - 1) {
                    _pageCtrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                  } else {
                    _finish();
                  }
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  backgroundColor: AppColors.primary,
                ),
                child: Text(
                  _page < _pages.length - 1 ? AppStrings.t(context, 'next') : AppStrings.t(context, 'getStarted'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
