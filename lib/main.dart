import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:provider/provider.dart';

import 'core/constants/ad_constants.dart';
import 'core/navigation/app_navigator.dart';
import 'core/services/ad_service.dart';
import 'core/services/storage_service.dart';
import 'providers/shell_provider.dart';
import 'providers/shop_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/trip_tools_provider.dart';
import 'providers/trips_provider.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/shop/shop_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/splash_screen.dart';
import 'widgets/coin_reward_listener.dart';

late final ThemeProvider appThemeProvider;
late final TripsProvider appTripsProvider;
late final TripToolsProvider appTripToolsProvider;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final imagePicker = ImagePickerPlatform.instance;
  if (imagePicker is ImagePickerAndroid) {
    imagePicker.useAndroidPhotoPicker = true;
  }
  await StorageService.instance.init();

  appThemeProvider = ThemeProvider();
  await appThemeProvider.init();

  appTripsProvider = TripsProvider();
  appTripToolsProvider = TripToolsProvider();

  runApp(const TripBoxApp());
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (AdConstants.isConfigured) unawaited(AdService.init());
  });
}

class TripBoxApp extends StatelessWidget {
  const TripBoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appThemeProvider),
        ChangeNotifierProvider.value(value: appTripsProvider),
        ChangeNotifierProvider.value(value: appTripToolsProvider),
        ChangeNotifierProvider(create: (_) => ShellProvider()),
        ChangeNotifierProvider(create: (_) => ShopProvider()..init()),
      ],
      child: Consumer2<ThemeProvider, ShopProvider>(
        builder: (context, theme, shop, _) {
          final preset = shop.activeTheme;
          SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ));

          return MaterialApp(
            navigatorKey: rootNavigatorKey,
            title: 'TripBox',
            debugShowCheckedModeBanner: false,
            theme: preset.lightTheme(),
            darkTheme: preset.darkTheme(),
            themeMode: theme.themeMode,
            locale: const Locale('en'),
            builder: (context, child) => CoinRewardListener(child: child ?? const SizedBox.shrink()),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            home: const SplashScreen(),
            routes: {
              '/shop': (_) => const ShopScreen(),
              '/search': (_) => const SearchScreen(),
              '/privacy': (_) => const PrivacyPolicyScreen(),
            },
          );
        },
      ),
    );
  }
}
