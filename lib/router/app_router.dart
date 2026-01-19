import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zyae/models/product.dart';
import 'package:zyae/models/supplier.dart';
import 'package:zyae/screens/edit_product_screen.dart';
import 'package:zyae/screens/edit_supplier_screen.dart';
import 'package:zyae/screens/home_screen.dart';
import 'package:zyae/screens/inventory_screen.dart';
import 'package:zyae/screens/main_screen.dart';
import 'package:zyae/screens/sales_screen.dart';
import 'package:zyae/screens/sell_screen.dart';
import 'package:zyae/screens/settings_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScreen(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/inventory',
              builder: (context, state) => const InventoryScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/sell',
              builder: (context, state) => const SellScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/sales',
              builder: (context, state) => const SalesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/edit-product',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final product = state.extra as Product?;
        return EditProductScreen(product: product);
      },
    ),
    GoRoute(
      path: '/edit-supplier',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final supplier = state.extra as Supplier?;
        return EditSupplierScreen(supplier: supplier);
      },
    ),
  ],
);
