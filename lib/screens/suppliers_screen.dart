import 'dart:io';
import 'package:flutter/material.dart';
import 'package:zyae/l10n/generated/app_localizations.dart';
import 'package:zyae/models/app_state.dart';
import 'package:zyae/models/supplier.dart';
import 'package:zyae/screens/edit_supplier_screen.dart';

class SuppliersScreen extends StatelessWidget {
  const SuppliersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final l10n = AppLocalizations.of(context)!;
    final suppliers = appState.suppliers;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.contacts),
      ),
      body: suppliers.isEmpty
          ? Center(child: Text(l10n.noSalesYet.replaceFirst('sales', 'contacts').replaceFirst('recorded', 'added'))) // Hacky fallback or just empty
          : ListView.builder(
              itemCount: suppliers.length,
              itemBuilder: (context, index) {
                final supplier = suppliers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: supplier.imagePath != null
                        ? FileImage(File(supplier.imagePath!))
                        : null,
                    child: supplier.imagePath == null
                        ? Text(supplier.name.isNotEmpty ? supplier.name[0].toUpperCase() : '?')
                        : null,
                  ),
                  title: Text(supplier.name),
                  subtitle: supplier.phoneNumber != null ? Text(supplier.phoneNumber!) : null,
                  onTap: () => _editSupplier(context, appState, supplier),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteSupplier(context, appState, supplier),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addSupplier(context, appState),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addSupplier(BuildContext context, AppState appState) async {
    final result = await Navigator.push<Supplier>(
      context,
      MaterialPageRoute(builder: (context) => const EditSupplierScreen()),
    );
    if (result != null) {
      await appState.addSupplier(result);
    }
  }

  Future<void> _editSupplier(BuildContext context, AppState appState, Supplier supplier) async {
    final result = await Navigator.push<Supplier>(
      context,
      MaterialPageRoute(builder: (context) => EditSupplierScreen(supplier: supplier)),
    );
    if (result != null) {
      await appState.updateSupplier(result);
    }
  }

  Future<void> _deleteSupplier(BuildContext context, AppState appState, Supplier supplier) async {
    // Simple delete for now
    await appState.deleteSupplier(supplier.id);
  }
}
