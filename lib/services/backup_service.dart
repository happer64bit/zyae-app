import 'dart:convert';
import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zyae/cubits/inventory/inventory_cubit.dart';
import 'package:zyae/cubits/sales/sales_cubit.dart';
import 'package:zyae/cubits/suppliers/suppliers_cubit.dart';
import 'package:zyae/models/product.dart';
import 'package:zyae/models/sale.dart';
import 'package:zyae/models/supplier.dart';
import 'package:zyae/repositories/data_repository.dart';

class BackupService {
  final DataRepository _repository;

  BackupService(this._repository);

  Future<void> exportData(BuildContext context) async {
    try {
      final products = _repository.getProducts();
      final sales = _repository.getSales();
      final suppliers = _repository.getSuppliers();

      final data = {
        'version': 1,
        'timestamp': DateTime.now().toIso8601String(),
        'products': products.map((p) => p.toJson()).toList(),
        'sales': sales.map((s) => s.toJson()).toList(),
        'suppliers': suppliers.map((s) => s.toJson()).toList(),
      };

      final jsonString = jsonEncode(data);
      final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'zyae_backup_$dateStr.json';

      // On Mobile, we often can't just write to any path.
      // We write to temp and then Share/Save.
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);

      if (Platform.isAndroid || Platform.isIOS) {
        final shareResult = await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path)],
            subject: 'Zyae Backup $dateStr',
          ),
        );

        if (shareResult.status == ShareResultStatus.success &&
            context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Backup exported successfully')),
          );
        }
      } else {
        final outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Backup',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['json'],
        );

        if (outputFile != null) {
          await file.copy(outputFile);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Backup saved successfully')),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }

  Future<void> importData(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        final data = jsonDecode(jsonString) as Map<String, dynamic>;

        // Basic validation
        if (!data.containsKey('products') || !data.containsKey('sales')) {
          throw Exception('Invalid backup file format');
        }

        // Restore Data
        await _repository.resetData();

        final products = (data['products'] as List)
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList();
        for (final p in products) {
          await _repository.addProduct(p);
        }

        final sales = (data['sales'] as List)
            .map((e) => Sale.fromJson(e as Map<String, dynamic>))
            .toList();
        for (final s in sales) {
          await _repository.addSale(s);
        }

        if (data.containsKey('suppliers')) {
          final suppliers = (data['suppliers'] as List)
              .map((e) => Supplier.fromJson(e as Map<String, dynamic>))
              .toList();
          for (final s in suppliers) {
            await _repository.addSupplier(s);
          }
        }

        // Reload Cubits
        if (context.mounted) {
          context.read<InventoryCubit>().loadInventory();
          context.read<SalesCubit>().loadSales();
          context.read<SuppliersCubit>().loadSuppliers();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data restored successfully')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
      }
    }
  }

  Future<void> exportToExcel(BuildContext context) async {
    try {
      final excel = Excel.createExcel();

      // Products Sheet
      final Sheet sheet1 = excel['Products'];
      sheet1.appendRow([
        TextCellValue('ID'),
        TextCellValue('Name'),
        TextCellValue('Price'),
        TextCellValue('Quantity'),
        TextCellValue('Unit'),
        TextCellValue('Barcode'),
      ]);

      final products = _repository.getProducts();
      for (final p in products) {
        sheet1.appendRow([
          TextCellValue(p.id),
          TextCellValue(p.name),
          DoubleCellValue(p.price),
          DoubleCellValue(p.quantity),
          TextCellValue(p.unit),
          TextCellValue(p.barcode ?? ''),
        ]);
      }

      // Sales Sheet
      final Sheet sheet2 = excel['Sales'];
      sheet2.appendRow([
        TextCellValue('ID'),
        TextCellValue('Date'),
        TextCellValue('Total Items'),
        TextCellValue('Total Amount'),
        TextCellValue('Items'),
      ]);

      final sales = _repository.getSales();
      for (final s in sales) {
        final itemDetails = s.items
            .map((i) => '${i.product.name} (${i.quantity})')
            .join(', ');

        sheet2.appendRow([
          TextCellValue(s.id),
          TextCellValue(DateFormat('yyyy-MM-dd HH:mm').format(s.date)),
          IntCellValue(s.totalItems),
          DoubleCellValue(s.total),
          TextCellValue(itemDetails),
        ]);
      }

      // Remove default sheet if created
      if (excel.sheets.containsKey('Sheet1') && excel.sheets.length > 1) {
        excel.delete('Sheet1');
      }

      final fileBytes = excel.save();
      if (fileBytes == null) {
        throw Exception('Failed to generate Excel file');
      }

      final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'zyae_export_$dateStr.xlsx';

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(fileBytes);

      if (Platform.isAndroid || Platform.isIOS) {
        final shareResult = await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path)],
            subject: 'Zyae Excel Export $dateStr',
          ),
        );
        if (shareResult.status == ShareResultStatus.success &&
            context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Excel exported successfully')),
          );
        }
            } else {
        final outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Excel Export',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['xlsx'],
        );

        if (outputFile != null) {
          await file.copy(outputFile);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Excel exported successfully')),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Excel export failed: $e')));
      }
    }
  }
}
