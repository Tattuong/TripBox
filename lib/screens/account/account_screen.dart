import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/navigation/app_navigator.dart';
import '../../providers/shop_provider.dart';
import '../../providers/shell_provider.dart';
import '../../providers/trips_provider.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/app_ui.dart';
import '../../widgets/coin_balance_chip.dart';
import '../friends/friends_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../moments/moments_screen.dart';
import '../shop/shop_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trips = context.watch<TripsProvider>();

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(gradient: AppColors.accountHeaderGradient),
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(AppStrings.t(context, 'account'), style: AppTypography.titleLarge().copyWith(fontSize: 28)),
                      ),
                      CoinBalanceChip(
                        variant: CoinChipVariant.header,
                        onTap: () => pushAppRoute(const ShopScreen()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                        child: Text(
                          trips.profileName.isNotEmpty ? trips.profileName[0] : 'T',
                          style: const TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(trips.profileName, style: AppTypography.titleLarge().copyWith(fontSize: 18)),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                                const SizedBox(width: 2),
                                Text(trips.profileLocation, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _QuickAction(
                        icon: Icons.card_giftcard_rounded,
                        label: AppStrings.t(context, 'rewards'),
                        onTap: () => pushAppRoute(const ShopScreen()),
                      ),
                      _QuickAction(
                        icon: Icons.favorite_border_rounded,
                        label: AppStrings.t(context, 'wishlist'),
                        onTap: () => pushAppRoute(const WishlistScreen()),
                      ),
                      _QuickAction(
                        icon: Icons.photo_library_outlined,
                        label: AppStrings.t(context, 'moment'),
                        onTap: () => pushAppRoute(const MomentsScreen()),
                      ),
                      _QuickAction(
                        icon: Icons.people_outline_rounded,
                        label: AppStrings.t(context, 'friends'),
                        onTap: () => pushAppRoute(const FriendsScreen()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: const SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: _MenuSection(
              items: [
                _MenuItem(icon: Icons.person_outline, label: AppStrings.t(context, 'editProfile'),
                    onTap: () => _editProfile(context)),
                _MenuItem(
                  icon: Icons.notifications_outlined,
                  label: AppStrings.t(context, 'notifications'),
                  onTap: () => AppToast.show(context, title: AppStrings.t(context, 'notificationsOn')),
                ),
                _MenuItem(
                  icon: Icons.card_giftcard_outlined,
                  label: AppStrings.t(context, 'inviteEarn'),
                  onTap: () {
                    final shop = context.read<ShopProvider>();
                    if (!shop.hasShare) {
                      AppToast.show(context, title: AppStrings.t(context, 'shareLocked'));
                      pushAppRoute(const ShopScreen(initialTab: ShopRewardsTab.features));
                      return;
                    }
                    Share.share(AppStrings.t(context, 'inviteMessage'));
                  },
                ),
                _MenuItem(
                  icon: Icons.calendar_today_outlined,
                  label: AppStrings.t(context, 'calendar'),
                  onTap: () => context.read<ShellProvider>().setIndex(3),
                ),
                _MenuItem(
                  icon: Icons.luggage_outlined,
                  label: AppStrings.t(context, 'itinerary'),
                  onTap: () => context.read<ShellProvider>().setIndex(3),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(child: const SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: _MenuSection(
              title: AppStrings.t(context, 'settings'),
              items: [
                _MenuItem(
                  icon: Icons.palette_outlined,
                  label: AppStrings.t(context, 'appearance'),
                  onTap: () => pushAppRoute(const ShopScreen(initialTab: ShopRewardsTab.themes)),
                ),
                _MenuItem(
                  icon: Icons.settings_outlined,
                  label: AppStrings.t(context, 'general'),
                  onTap: () => AppToast.show(context, title: AppStrings.t(context, 'generalSettings')),
                ),
                _MenuItem(
                  icon: Icons.help_outline,
                  label: AppStrings.t(context, 'helpCenter'),
                  onTap: () => AppToast.show(context, title: AppStrings.t(context, 'helpCenterMsg')),
                ),
                _MenuItem(
                  icon: Icons.privacy_tip_outlined,
                  label: AppStrings.t(context, 'privacyPolicy'),
                  onTap: () => pushAppNamed('/privacy'),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                AppStrings.t(context, 'version', {'version': '1.0.0'}),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editProfile(BuildContext context) async {
    final trips = context.read<TripsProvider>();
    final nameCtrl = TextEditingController(text: trips.profileName);
    final locCtrl = TextEditingController(text: trips.profileLocation);

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.t(context, 'editProfile')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: InputDecoration(labelText: AppStrings.t(context, 'profileName'))),
            TextField(controller: locCtrl, decoration: InputDecoration(labelText: AppStrings.t(context, 'profileLocation'))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppStrings.t(context, 'cancel'))),
          FilledButton(
            onPressed: () {
              trips.updateProfile(name: nameCtrl.text, location: locCtrl.text);
              AppToast.show(context, title: AppStrings.t(context, 'profileSaved'));
              Navigator.pop(ctx);
            },
            child: Text(AppStrings.t(context, 'save')),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _QuickAction({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 26),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String? title;
  final List<_MenuItem> items;

  const _MenuSection({this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!, style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
          ],
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(children: items),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _MenuItem({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
    );
  }
}
