import 'package:flutter/material.dart';

enum ShopItemType {
  theme,
  background,
  skin,
  feature,
  removeAds,
}

enum ShopItemCategory {
  themes,
  backgrounds,
  skins,
  features,
  premium,
}

class ShopItem {
  final String id;
  final String nameKey;
  final String descKey;
  final int price;
  final ShopItemType type;
  final ShopItemCategory category;
  final IconData icon;
  final bool oneTime;

  const ShopItem({
    required this.id,
    required this.nameKey,
    required this.descKey,
    required this.price,
    required this.type,
    required this.category,
    required this.icon,
    this.oneTime = true,
  });
}

class ShopCatalog {
  ShopCatalog._();

  static const String defaultThemeId = 'theme_default';
  static const String defaultBackgroundId = 'bg_default';
  static const String defaultSkinId = 'skin_default';

  static const List<ShopItem> items = [
    ShopItem(
      id: 'remove_ads',
      nameKey: 'shopRemoveAds',
      descKey: 'shopRemoveAdsDesc',
      price: 500,
      type: ShopItemType.removeAds,
      category: ShopItemCategory.premium,
      icon: Icons.block_outlined,
    ),
    ShopItem(
      id: 'theme_ocean',
      nameKey: 'shopThemeOcean',
      descKey: 'shopThemeOceanDesc',
      price: 200,
      type: ShopItemType.theme,
      category: ShopItemCategory.themes,
      icon: Icons.water_outlined,
    ),
    ShopItem(
      id: 'theme_sunset',
      nameKey: 'shopThemeSunset',
      descKey: 'shopThemeSunsetDesc',
      price: 200,
      type: ShopItemType.theme,
      category: ShopItemCategory.themes,
      icon: Icons.wb_twilight_outlined,
    ),
    ShopItem(
      id: 'theme_forest',
      nameKey: 'shopThemeForest',
      descKey: 'shopThemeForestDesc',
      price: 250,
      type: ShopItemType.theme,
      category: ShopItemCategory.themes,
      icon: Icons.forest_outlined,
    ),
    ShopItem(
      id: 'bg_sky',
      nameKey: 'shopBgSky',
      descKey: 'shopBgSkyDesc',
      price: 150,
      type: ShopItemType.background,
      category: ShopItemCategory.backgrounds,
      icon: Icons.wb_cloudy_outlined,
    ),
    ShopItem(
      id: 'bg_sand',
      nameKey: 'shopBgSand',
      descKey: 'shopBgSandDesc',
      price: 150,
      type: ShopItemType.background,
      category: ShopItemCategory.backgrounds,
      icon: Icons.beach_access_outlined,
    ),
    ShopItem(
      id: 'bg_aurora',
      nameKey: 'shopBgAurora',
      descKey: 'shopBgAuroraDesc',
      price: 180,
      type: ShopItemType.background,
      category: ShopItemCategory.backgrounds,
      icon: Icons.auto_awesome_outlined,
    ),
    ShopItem(
      id: 'skin_soft',
      nameKey: 'shopSkinSoft',
      descKey: 'shopSkinSoftDesc',
      price: 150,
      type: ShopItemType.skin,
      category: ShopItemCategory.skins,
      icon: Icons.rounded_corner,
    ),
    ShopItem(
      id: 'skin_bold',
      nameKey: 'shopSkinBold',
      descKey: 'shopSkinBoldDesc',
      price: 180,
      type: ShopItemType.skin,
      category: ShopItemCategory.skins,
      icon: Icons.crop_square_outlined,
    ),
    ShopItem(
      id: 'feat_unlimited_trips',
      nameKey: 'shopFeatUnlimitedTrips',
      descKey: 'shopFeatUnlimitedTripsDesc',
      price: 300,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.all_inclusive,
    ),
    ShopItem(
      id: 'feat_export',
      nameKey: 'shopFeatExport',
      descKey: 'shopFeatExportDesc',
      price: 200,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.ios_share_outlined,
    ),
    ShopItem(
      id: 'feat_offline',
      nameKey: 'shopFeatOffline',
      descKey: 'shopFeatOfflineDesc',
      price: 250,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.offline_bolt_outlined,
    ),
    ShopItem(
      id: 'feat_weather',
      nameKey: 'shopFeatWeather',
      descKey: 'shopFeatWeatherDesc',
      price: 200,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.wb_sunny_outlined,
    ),
    ShopItem(
      id: 'feat_share',
      nameKey: 'shopFeatShare',
      descKey: 'shopFeatShareDesc',
      price: 180,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.share_outlined,
    ),
    ShopItem(
      id: 'feat_premium_cat',
      nameKey: 'shopFeatPremiumCat',
      descKey: 'shopFeatPremiumCatDesc',
      price: 220,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.category_outlined,
    ),
  ];

  static ShopItem? find(String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }
}
