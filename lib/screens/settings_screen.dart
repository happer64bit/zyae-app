import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zyae/cubits/settings/settings_cubit.dart';
import 'package:zyae/l10n/generated/app_localizations.dart';
import 'package:zyae/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    l10n.settings,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  _buildSectionHeader(l10n.language),
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
                  const Divider(),
                  _buildSectionHeader(l10n.dataManagement),
                  ListTile(
                    leading: const Icon(Icons.download, color: AppTheme.primaryColor),
                    title: Text(l10n.exportData),
                    onTap: () async {
                      // TODO: Implement actual export logic
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.dataExported)),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.upload, color: AppTheme.primaryColor),
                    title: Text(l10n.importData),
                    onTap: () async {
                      // TODO: Implement actual import logic
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.dataImported)),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.delete_forever, color: AppTheme.errorColor),
                    title: Text(
                      l10n.resetData,
                      style: const TextStyle(color: AppTheme.errorColor),
                    ),
                    onTap: () => _showResetConfirmation(context, l10n),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
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
    return ListTile(
      title: Text(title),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppTheme.primaryColor)
          : null,
      onTap: () => context.read<SettingsCubit>().setLocale(locale),
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
            child: Text(l10n.cancel),
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
