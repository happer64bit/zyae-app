import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zyae/cubits/cart/cart_cubit.dart';
import 'package:zyae/cubits/inventory/inventory_cubit.dart';
import 'package:zyae/cubits/sales/sales_cubit.dart';
import 'package:zyae/cubits/settings/settings_cubit.dart';
import 'package:zyae/cubits/suppliers/suppliers_cubit.dart';
import 'package:zyae/l10n/generated/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zyae/models/product.dart';
import 'package:zyae/models/sale.dart';
import 'package:zyae/models/supplier.dart';
import 'package:zyae/repositories/data_repository.dart';
import 'package:zyae/router/app_router.dart';
import 'package:zyae/theme/app_theme.dart';

void main() async {
  await Hive.initFlutter();
  
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(SaleItemAdapter());
  Hive.registerAdapter(SaleAdapter());
  Hive.registerAdapter(SupplierAdapter());

  final dataRepository = DataRepository();
  await dataRepository.init();
  
  runApp(MyApp(dataRepository: dataRepository));
}

class MyApp extends StatelessWidget {
  final DataRepository dataRepository;

  const MyApp({super.key, required this.dataRepository});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: dataRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => InventoryCubit(repository: dataRepository)..loadInventory(),
          ),
          BlocProvider(
            create: (context) => SalesCubit(repository: dataRepository)..loadSales(),
          ),
          BlocProvider(
            create: (context) => SuppliersCubit(repository: dataRepository)..loadSuppliers(),
          ),
          BlocProvider(
            create: (context) => SettingsCubit(repository: dataRepository),
          ),
        ],
        child: Builder(
          builder: (context) {
            // CartCubit needs Inventory and Sales cubits
            return BlocProvider(
              create: (context) => CartCubit(
                repository: dataRepository,
                inventoryCubit: context.read<InventoryCubit>(),
                salesCubit: context.read<SalesCubit>(),
              ),
              child: const AppView(),
            );
          },
        ),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return MaterialApp.router(
          title: 'Zyae',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getTheme(state.locale),
          locale: state.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: appRouter,
        );
      },
    );
  }
}
