import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zyae/cubits/suppliers/suppliers_cubit.dart';
import 'package:zyae/l10n/generated/app_localizations.dart';
import 'package:zyae/models/supplier.dart';
import 'package:zyae/screens/edit_supplier_screen.dart';
import 'package:zyae/theme/app_theme.dart';
import 'package:zyae/widgets/touchable_opacity.dart';

class SuppliersScreen extends StatelessWidget {
  const SuppliersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: BlocBuilder<SuppliersCubit, SuppliersState>(
          builder: (context, state) {
            if (state is SuppliersLoading) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
            }
            
            if (state is SuppliersError) {
              return Center(
                child: Text(
                  '${l10n.error}: ${state.message}',
                  style: const TextStyle(color: AppTheme.errorColor),
                ),
              );
            }

            if (state is SuppliersLoaded) {
              final suppliers = state.suppliers;
              
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          if (Navigator.canPop(context))
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: TouchableOpacity(
                                onTap: () => Navigator.pop(context),
                                child: const Icon(Icons.arrow_back, color: AppTheme.textPrimary, size: 24),
                              ),
                            ),
                          Text(
                            l10n.contacts,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          TouchableOpacity(
                            onTap: () => _addSupplier(context),
                            child: const Icon(Icons.add_circle, color: AppTheme.primaryColor, size: 32),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (suppliers.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Text(
                          l10n.noContactsAdded,
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final supplier = suppliers[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                            child: TouchableOpacity(
                              onTap: () => _editSupplier(context, supplier),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.borderColor),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppTheme.backgroundColor,
                                      backgroundImage: supplier.imagePath != null
                                          ? FileImage(File(supplier.imagePath!))
                                          : null,
                                      child: supplier.imagePath == null
                                          ? Text(
                                              supplier.name.isNotEmpty ? supplier.name[0].toUpperCase() : '?',
                                              style: const TextStyle(color: AppTheme.textSecondary),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            supplier.name,
                                            style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                                          ),
                                          if (supplier.phoneNumber != null)
                                            Text(
                                              supplier.phoneNumber!,
                                              style: const TextStyle(color: AppTheme.textSecondary),
                                            ),
                                        ],
                                      ),
                                    ),
                                    TouchableOpacity(
                                      onTap: () => _deleteSupplier(context, supplier),
                                      child: const Icon(Icons.delete, color: AppTheme.errorColor),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: suppliers.length,
                      ),
                    ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Future<void> _addSupplier(BuildContext context) async {
    final result = await Navigator.push<Supplier>(
      context,
      MaterialPageRoute(builder: (context) => const EditSupplierScreen()),
    );
    if (result != null && context.mounted) {
      context.read<SuppliersCubit>().addSupplier(result);
    }
  }

  Future<void> _editSupplier(BuildContext context, Supplier supplier) async {
    final result = await Navigator.push<Supplier>(
      context,
      MaterialPageRoute(builder: (context) => EditSupplierScreen(supplier: supplier)),
    );
    if (result != null && context.mounted) {
      context.read<SuppliersCubit>().updateSupplier(result);
    }
  }

  Future<void> _deleteSupplier(BuildContext context, Supplier supplier) async {
    context.read<SuppliersCubit>().deleteSupplier(supplier.id);
  }
}

