import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:zyae/cubits/settings/settings_cubit.dart';
import 'package:zyae/l10n/generated/app_localizations.dart';
import 'package:zyae/repositories/data_repository.dart';
import 'package:zyae/services/backup_service.dart';
import 'package:zyae/theme/app_theme.dart';
import 'package:zyae/widgets/touchable_opacity.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repository = context.read<DataRepository>();
    final backupService = BackupService(repository);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                l10n.settings,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionHeader(context, l10n.language),
            _buildLanguageOption(
              context,
              l10n.english,
              const Locale('en'),
            ),
            _buildLanguageOption(
              context,
              l10n.burmese,
              const Locale('my'),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(color: AppTheme.borderColor),
            ),
            _buildSectionHeader(context, l10n.dataManagement),
            _SettingsTile(
              icon: LucideIcons.download,
              title: l10n.exportData,
              subtitle: 'Backup all data to a JSON file',
              onTap: () => backupService.exportData(context),
            ),
            _SettingsTile(
              icon: LucideIcons.upload,
              title: l10n.importData,
              subtitle: 'Restore data from a JSON file',
              onTap: () => backupService.importData(context),
            ),
            _SettingsTile(
              icon: LucideIcons.sheet,
              title: l10n.exportToExcel,
              subtitle: 'Export products and sales to Excel',
              onTap: () => backupService.exportToExcel(context),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(color: AppTheme.borderColor),
            ),
            _SettingsTile(
              icon: LucideIcons.trash2,
              title: l10n.resetData,
              titleColor: AppTheme.errorColor,
              iconColor: AppTheme.errorColor,
              onTap: () => _showResetConfirmation(context, l10n),
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'Made by Wint Khant Lin',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String title,
    Locale locale,
  ) {
    final currentLocale = context.watch<SettingsCubit>().state.locale;
    final isSelected = currentLocale.languageCode == locale.languageCode;
    
    return TouchableOpacity(
      onTap: () => context.read<SettingsCubit>().setLocale(locale),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                ),
              ),
            ),
            if (isSelected)
              const Icon(LucideIcons.circleCheck, color: AppTheme.primaryColor, size: 24),
          ],
        ),
      ),
    );
  }

  void _showResetConfirmation(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.resetData),
        content: Text(l10n.resetDataConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel, style: const TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              await context.read<SettingsCubit>().resetData();
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.dataReset)),
                );
              }
            },
            child: Text(
              l10n.delete,
              style: const TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? titleColor;
  final Color? iconColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.titleColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return TouchableOpacity(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? AppTheme.textPrimary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: titleColor ?? AppTheme.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, color: AppTheme.borderColor, size: 24),
          ],
        ),
      ),
    );
  }
}
