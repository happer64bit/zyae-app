import 'package:flutter/material.dart';
import 'package:zyae/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:zyae/models/app_state.dart';
import 'package:zyae/theme/app_theme.dart';

class MainScreen extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainScreen({
    super.key,
    required this.navigationShell,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstLaunch();
    });
  }

  void _checkFirstLaunch() {
    final appState = AppStateScope.of(context);
    if (appState.isFirstLaunch) {
      _showLanguagePicker(appState);
    }
  }

  void _showLanguagePicker(AppState appState) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('Select Language / ဘာသာစကားရွေးပါ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English'),
                onTap: () {
                  appState.setLocale(const Locale('en'));
                  appState.completeFirstLaunch();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Burmese (မြန်မာ)'),
                onTap: () {
                  appState.setLocale(const Locale('my'));
                  appState.completeFirstLaunch();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          elevation: 0,
          backgroundColor: Colors.white,
          selectedIndex: widget.navigationShell.currentIndex,
          onDestinationSelected: _onItemTapped,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: l10n.home,
            ),
            NavigationDestination(
              icon: const Icon(Icons.inventory_2_outlined),
              selectedIcon: const Icon(Icons.inventory_2),
              label: l10n.inventory,
            ),
            NavigationDestination(
              icon: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                ),
              ),
              label: l10n.sell,
            ),
            NavigationDestination(
              icon: const Icon(Icons.receipt_long_outlined),
              selectedIcon: const Icon(Icons.receipt_long),
              label: l10n.sales,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: l10n.settings,
            ),
          ],
        ),
      ),
    );
  }
}
