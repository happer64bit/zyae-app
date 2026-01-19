import 'package:flutter/material.dart';
import 'package:zyae/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zyae/cubits/settings/settings_cubit.dart';
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
    final settingsCubit = context.read<SettingsCubit>();
    if (settingsCubit.state.isFirstLaunch) {
      _showLanguagePicker(settingsCubit);
    }
  }

  void _showLanguagePicker(SettingsCubit settingsCubit) {
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
                  settingsCubit.setLocale(const Locale('en'));
                  settingsCubit.completeFirstLaunch();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Burmese (မြန်မာ)'),
                onTap: () {
                  settingsCubit.setLocale(const Locale('my'));
                  settingsCubit.completeFirstLaunch();
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
        child: BottomNavigationBar(
          currentIndex: widget.navigationShell.currentIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: l10n.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.inventory_2_outlined),
              activeIcon: const Icon(Icons.inventory_2),
              label: l10n.inventory,
            ),
            BottomNavigationBarItem(
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
            BottomNavigationBarItem(
              icon: const Icon(Icons.receipt_long_outlined),
              activeIcon: const Icon(Icons.receipt_long),
              label: l10n.sales,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined),
              activeIcon: const Icon(Icons.settings),
              label: l10n.settings,
            ),
          ],
        ),
      ),
    );
  }
}
