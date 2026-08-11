import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/cover_photo_picker.dart';
import '../models/app_theme_preset.dart';
import '../models/trip_member.dart';
import '../providers/shop_provider.dart';
import 'app_ui.dart';

class TbBackground extends StatelessWidget {
  final Widget child;

  const TbBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final bg = context.select<ShopProvider, AppBackground>((s) => s.activeBackground);
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(decoration: BoxDecoration(gradient: bg.gradient)),
        child,
      ],
    );
  }
}

class TbScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool extendBody;

  const TbScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.extendBody = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: extendBody,
      backgroundColor: AppColors.background,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: TbBackground(child: body),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

class TbBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  final VoidCallback onCreateTap;

  const TbBottomNav({
    super.key,
    required this.index,
    required this.onTap,
    required this.onCreateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.navBar,
        border: Border(top: BorderSide(color: AppColors.border.withValues(alpha: 0.8))),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_rounded, label: 'Home', selected: index == 0, onTap: () => onTap(0)),
              _NavItem(icon: Icons.explore_rounded, label: 'Explore', selected: index == 1, onTap: () => onTap(1)),
              _CenterButton(onTap: onCreateTap),
              _NavItem(icon: Icons.luggage_rounded, label: 'Itinerary', selected: index == 3, onTap: () => onTap(3)),
              _NavItem(icon: Icons.person_rounded, label: 'Account', selected: index == 4, onTap: () => onTap(4)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: selected
                  ? BoxDecoration(
                      color: AppColors.primarySoft,
                      shape: BoxShape.circle,
                    )
                  : null,
              child: Icon(
                icon,
                color: selected ? AppColors.navActive : AppColors.navInactive,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CenterButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}

class TbSearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;

  const TbSearchBar({
    super.key,
    required this.hint,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final field = readOnly
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              hint,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
          )
        : TextField(
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: readOnly ? onTap : null,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppColors.textMuted, size: 20),
              const SizedBox(width: 8),
              Expanded(child: field),
            ],
          ),
        ),
      ),
    );
  }
}

class TbTripCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final int hotelCount;
  final int destinationCount;
  final VoidCallback? onTap;
  final bool compact;
  final List<TripMember>? members;
  final String? dateRange;

  const TbTripCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.hotelCount = 0,
    this.destinationCount = 0,
    this.onTap,
    this.compact = false,
    this.members,
    this.dateRange,
  });

  @override
  Widget build(BuildContext context) {
    final cardStyle = context.select<ShopProvider, CardStyle>((s) => s.activeCardStyle);

    if (compact) {
      return _CompactCard(
        title: title,
        subtitle: subtitle,
        imageUrl: imageUrl,
        hotelCount: hotelCount,
        destinationCount: destinationCount,
        onTap: onTap,
        borderRadius: cardStyle.borderRadius,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(cardStyle.borderRadius),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(cardStyle.borderRadius),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 16, offset: const Offset(0, 6)),
            ],
          ),
          child: ClipRRect(
          borderRadius: BorderRadius.circular(cardStyle.borderRadius),
          child: SizedBox(
            height: 180,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.hardEdge,
              children: [
                _TripCardBackground(url: imageUrl),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (dateRange != null)
                        Text(
                          dateRange!,
                          style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                        )
                      else
                        const SizedBox.shrink(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                          if (members != null && members!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _AvatarRow(members: members!),
                                  const SizedBox(height: 4),
                                  Text(
                                    members!.map((m) => m.firstName).join(' · '),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}

class _CompactCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final int hotelCount;
  final int destinationCount;
  final VoidCallback? onTap;
  final double borderRadius;

  const _CompactCard({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.hotelCount,
    required this.destinationCount,
    this.onTap,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: SizedBox(
        width: 200,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 110,
                  width: 200,
                  child: _NetworkImage(url: imageUrl),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.titleLarge().copyWith(fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (hotelCount > 0) ...[
                            const Icon(Icons.hotel_outlined, size: 12, color: AppColors.textMuted),
                            const SizedBox(width: 2),
                            Text('$hotelCount', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                            const SizedBox(width: 8),
                          ],
                          if (destinationCount > 0) ...[
                            const Icon(Icons.place_outlined, size: 12, color: AppColors.textMuted),
                            const SizedBox(width: 2),
                            Text('$destinationCount', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}

class TbTripImage extends StatelessWidget {
  final String url;

  const TbTripImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) => TripCoverImage(url: url);
}

class _TripCardBackground extends StatelessWidget {
  final String url;

  const _TripCardBackground({required this.url});

  @override
  Widget build(BuildContext context) => TripCoverImage(url: url);
}

class _AvatarRow extends StatelessWidget {
  final List<TripMember> members;

  const _AvatarRow({required this.members});

  @override
  Widget build(BuildContext context) {
    final visible = members.take(4).toList();
    if (visible.isEmpty) return const SizedBox.shrink();
    final width = 28.0 + (visible.length - 1) * 18.0;
    return SizedBox(
      height: 28,
      width: width,
      child: Stack(
        children: [
          for (var i = 0; i < visible.length; i++)
            Positioned(
              left: i * 18.0,
              child: _Avatar(initial: visible[i].initial),
            ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initial;

  const _Avatar({required this.initial});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: Text(
          initial.isNotEmpty ? initial[0] : '?',
          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _NetworkImage extends StatelessWidget {
  final String url;

  const _NetworkImage({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return TripCoverImage.placeholder(iconSize: 48);
    }
    return TripCoverImage(url: url);
  }
}

class TbCategoryGrid extends StatelessWidget {
  final List<TravelCategoryItem> categories;
  final ValueChanged<String>? onCategoryTap;

  static const _cellHeight = 74.0;
  static const _spacing = 8.0;

  const TbCategoryGrid({super.key, required this.categories, this.onCategoryTap});

  @override
  Widget build(BuildContext context) {
    final rowCount = (categories.length / 4).ceil();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var row = 0; row < rowCount; row++) ...[
          if (row > 0) const SizedBox(height: _spacing),
          Row(
            children: [
              for (var col = 0; col < 4; col++) ...[
                if (col > 0) const SizedBox(width: _spacing),
                Expanded(
                  child: _cellAt(row, col),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _cellAt(int row, int col) {
    final index = row * 4 + col;
    if (index >= categories.length) {
      return const SizedBox(height: _cellHeight);
    }
    return SizedBox(
      height: _cellHeight,
      child: _CategoryCell(
        cat: categories[index],
        onTap: onCategoryTap != null ? () => onCategoryTap!(categories[index].id) : null,
      ),
    );
  }
}

class _CategoryCell extends StatelessWidget {
  final TravelCategoryItem cat;
  final VoidCallback? onTap;

  const _CategoryCell({required this.cat, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bgColor = cat.locked ? cat.bgColor.withValues(alpha: 0.55) : cat.bgColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: cat.color.withValues(alpha: 0.15),
        highlightColor: cat.color.withValues(alpha: 0.08),
        child: Ink(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: cat.color.withValues(alpha: cat.locked ? 0.08 : 0.12)),
            boxShadow: [
              BoxShadow(
                color: cat.color.withValues(alpha: cat.locked ? 0.04 : 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      cat.emoji,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24, color: cat.locked ? AppColors.textMuted : null),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cat.label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: cat.locked ? AppColors.textMuted : cat.color,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (cat.locked)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_rounded, size: 12, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class TravelCategoryItem {
  final String id;
  final String label;
  final String emoji;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final bool locked;

  const TravelCategoryItem({
    required this.id,
    required this.label,
    required this.emoji,
    required this.icon,
    required this.color,
    required this.bgColor,
    this.locked = false,
  });
}

/// Centered empty placeholder with hint text and optional action button (mockup style).
class TbEmptyState extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData actionIcon;

  const TbEmptyState({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.actionIcon = Icons.add_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              Material(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
                elevation: 3,
                shadowColor: AppColors.primary.withValues(alpha: 0.35),
                child: InkWell(
                  onTap: onAction,
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(actionIcon, color: Colors.white, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          actionLabel!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class TbSheetHandle extends StatelessWidget {
  const TbSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 8),
        width: 40,
        height: 4,
        decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
      ),
    );
  }
}

class TbFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const TbFilterChip({super.key, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
      ),
    );
  }
}
