import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripbox/core/services/storage_service.dart';
import 'package:tripbox/providers/shop_provider.dart';
import 'package:tripbox/widgets/coin_purchase_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('buy stars sheet stays partial and shows packs area without a full-screen spinner', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();

    final shop = ShopProvider();
    addTearDown(shop.dispose);

    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: shop,
        child: const MaterialApp(
          home: Scaffold(body: _OpenSheet()),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Buy Stars'), findsOneWidget);
    expect(find.text('Google Billing unavailable on this device'), findsOneWidget);
    expect(find.text('Processing purchase...'), findsNothing);

    final screenHeight = tester.view.physicalSize.height / tester.view.devicePixelRatio;
    final sheetTop = tester.getTopLeft(find.text('Buy Stars')).dy;
    expect(sheetTop, greaterThan(screenHeight * 0.2));
    expect(find.text('open'), findsOneWidget);
  });
}

class _OpenSheet extends StatelessWidget {
  const _OpenSheet();

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => CoinPurchaseSheet.show(context),
      child: const Text('open'),
    );
  }
}
