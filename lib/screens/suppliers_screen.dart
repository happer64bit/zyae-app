import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zyae/cubits/suppliers/suppliers_cubit.dart';
import 'package:zyae/l10n/generated/app_localizations.dart';
import 'package:zyae/models/supplier.dart';
import 'package:zyae/screens/edit_supplier_screen.dart';
import 'package:zyae/theme/app_theme.dart';

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
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
                                onPressed: () => Navigator.pop(context),
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
                            child: Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: AppTheme.borderColor),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
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
                                title: Text(
                                  supplier.name,
                                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                                ),
                                subtitle: supplier.phoneNumber != null 
                                  ? Text(
                                      supplier.phoneNumber!,
                                      style: const TextStyle(color: AppTheme.textSecondary),
                                    ) 
                                  : null,
                                onTap: () => _editSupplier(context, supplier),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: AppTheme.errorColor),
                                  onPressed: () => _deleteSupplier(context, supplier),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addSupplier(context),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.surfaceColor,
        child: const Icon(Icons.add),
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

