import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/navigation/app_navigator.dart';
import '../../models/trip.dart';
import '../../models/trip_member.dart';
import '../../providers/shop_provider.dart';
import '../../providers/trips_provider.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/trip_design.dart';
import '../shop/shop_screen.dart';

class InviteFriendSheet {
  static Future<void> show(TripEntry trip) async {
    await showAppModal(_InviteFriendSheet(tripId: trip.id));
  }
}

class _InviteFriendSheet extends StatefulWidget {
  final String tripId;

  const _InviteFriendSheet({required this.tripId});

  @override
  State<_InviteFriendSheet> createState() => _InviteFriendSheetState();
}

class _InviteFriendSheetState extends State<_InviteFriendSheet> {
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _addFriend() async {
    final trips = context.read<TripsProvider>();
    final trip = trips.tripById(widget.tripId);
    if (trip == null) return;

    final ok = await trips.addMember(trip.id, _nameCtrl.text);
    if (!mounted) return;
    if (ok) {
      _nameCtrl.clear();
      AppToast.show(context, title: AppStrings.t(context, 'friendAdded'));
    } else {
      AppToast.show(context, title: AppStrings.t(context, 'friendExists'));
    }
  }

  Future<void> _shareInvite() async {
    final shop = context.read<ShopProvider>();
    if (!shop.hasShare) {
      AppToast.show(context, title: AppStrings.t(context, 'shareLocked'));
      pushAppRoute(const ShopScreen(initialTab: ShopRewardsTab.features));
      return;
    }
    final trips = context.read<TripsProvider>();
    final trip = trips.tripById(widget.tripId);
    if (trip == null) return;
    await Share.share(trips.inviteMessageFor(trip), subject: trip.title);
  }

  @override
  Widget build(BuildContext context) {
    final trips = context.watch<TripsProvider>();
    final trip = trips.tripById(widget.tripId);
    if (trip == null) {
      return const SizedBox.shrink();
    }

    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.75),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TbSheetHandle(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppStrings.t(context, 'inviteFriend'),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  AppStrings.t(context, 'inviteFriendHint'),
                  style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameCtrl,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          hintText: AppStrings.t(context, 'friendName'),
                          filled: true,
                          fillColor: AppColors.surfaceVariant,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        onSubmitted: (_) => _addFriend(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: _addFriend,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(AppStrings.t(context, 'addFriend')),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _shareInvite,
                    icon: const Icon(Icons.share_outlined, size: 18),
                    label: Text(AppStrings.t(context, 'shareInvite')),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  children: [
                    Text(
                      AppStrings.t(context, 'travelCompanions'),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...trip.members.map((m) => _MemberTile(
                          member: m,
                          onRemove: m.isOwner
                              ? null
                              : () => context.read<TripsProvider>().removeMember(trip.id, m.id),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final TripMember member;
  final VoidCallback? onRemove;

  const _MemberTile({required this.member, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
          child: Text(
            member.initial,
            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
          ),
        ),
        title: Text(member.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: member.isOwner ? Text(AppStrings.t(context, 'tripOwner')) : null,
        trailing: onRemove != null
            ? IconButton(
                icon: const Icon(Icons.person_remove_outlined, color: AppColors.textMuted, size: 20),
                onPressed: onRemove,
              )
            : null,
      ),
    );
  }
}
