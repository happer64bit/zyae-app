import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:zyae/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:zyae/theme/app_theme.dart';
import 'package:zyae/widgets/touchable_opacity.dart';

class MainScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScreen({
    super.key,
    required this.navigationShell,
  });

  void _onItemTapped(int index) {
    HapticFeedback.selectionClick();
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentIndex = navigationShell.currentIndex;

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: SafeArea(child: navigationShell),
      bottomNavigationBar: Container(
        height: 70 + bottomPadding,
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          border: const Border(top: BorderSide(color: AppTheme.borderColor)),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                icon: LucideIcons.house,
                label: l10n.home,
                isSelected: currentIndex == 0,
                onTap: () => _onItemTapped(0),
              ),

              _NavBarItem(
                icon: LucideIcons.box,
                label: l10n.inventory,
                isSelected: currentIndex == 1,
                onTap: () => _onItemTapped(1),
              ),

              _MiddleActionButton(
                isSelected: currentIndex == 2,
                onTap: () => _onItemTapped(2),
              ),

              // 4. Sales
              _NavBarItem(
                icon: LucideIcons.receipt,
                label: l10n.sales,
                isSelected: currentIndex == 3,
                onTap: () => _onItemTapped(3),
              ),

              _NavBarItem(
                icon: LucideIcons.settings,
                label: l10n.settings,
                isSelected: currentIndex == 4,
                onTap: () => _onItemTapped(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A standard navigation item with animations and Burmese-safe text
class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppTheme.primaryColor : AppTheme.textSecondary;
    
    return TouchableOpacity(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 2),
          // Using flexible text to handle Burmese height
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: color,
              fontFamily: 'Pyidaungsu', // Ensure you have a font that supports Burmese well
              height: 1.2, // Fixes clipping for Burmese characters
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }
}

/// The distinctive middle button
class _MiddleActionButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _MiddleActionButton({
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TouchableOpacity(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            LucideIcons.shoppingBasket,
            color: AppTheme.surfaceColor,
            // Scale up slightly when selected
            size: isSelected ? 26 : 22,
          ),
        ),
      ),
    );
  }
}