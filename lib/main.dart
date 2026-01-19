import 'package:flutter/material.dart';
import 'package:zyae/l10n/generated/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zyae/models/app_state.dart';
import 'package:zyae/models/product.dart';
import 'package:zyae/models/sale.dart';
import 'package:zyae/models/supplier.dart';
import 'package:zyae/router/app_router.dart';
import 'package:zyae/theme/app_theme.dart';

void main() async {
  await Hive.initFlutter();
  
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(SaleItemAdapter());
  Hive.registerAdapter(SaleAdapter());
  Hive.registerAdapter(SupplierAdapter());

  final appState = AppState();
  await appState.init();
  
  runApp(
    AppStateScope(
      notifier: appState,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    
    return MaterialApp.router(
      title: 'Zyae Shop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: appState.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: appRouter,
    );
  }
}
