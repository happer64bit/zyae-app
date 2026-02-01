import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zyae/cubits/inventory/inventory_cubit.dart';
import 'package:zyae/cubits/suppliers/suppliers_cubit.dart';
import 'package:zyae/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:zyae/models/product.dart';
import 'package:zyae/screens/barcode_scanner_screen.dart';
import 'package:zyae/screens/edit_supplier_screen.dart';
import 'package:zyae/theme/app_theme.dart';

import 'package:zyae/widgets/touchable_opacity.dart';

class EditProductScreen extends StatefulWidget {
  final Product? product;

  const EditProductScreen({super.key, this.product});

  bool get isNew => product == null;

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _lowStockController;
  late TextEditingController _barcodeController;
  late TextEditingController _supplierController;
  
  DateTime? _expiryDate;
  String? _imagePath;
  late String _selectedUnit;

  final List<String> _units = ['pcs', 'kg', 'L'];

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameController = TextEditingController(text: product?.name ?? '');
    _priceController = TextEditingController(
      text: product != null ? product.price.toStringAsFixed(0) : '',
    );
    _stockController = TextEditingController(
      text: product != null ? product.quantity.toStringAsFixed(0) : '',
    );
    _lowStockController = TextEditingController(
      text: product != null ? product.lowStockThreshold.toString() : '',
    );
    _barcodeController = TextEditingController(text: product?.barcode ?? '');
    _supplierController = TextEditingController(text: product?.supplierContact ?? '');
    _expiryDate = product?.expiryDate;
    _imagePath = product?.imagePath;
    _selectedUnit = product?.unit ?? 'kg';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _lowStockController.dispose();
    _barcodeController.dispose();
    _supplierController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  Future<void> _scanBarcode() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
    );
    if (result is String) {
      setState(() {
        _barcodeController.text = result;
      });
    }
  }

  Future<void> _pickExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  Future<void> _selectSupplier() async {
    final l10n = AppLocalizations.of(context)!;
    final suppliersCubit = context.read<SuppliersCubit>();
    
    // Ensure suppliers are loaded
    if (suppliersCubit.state is! SuppliersLoaded) {
      await suppliersCubit.loadSuppliers();
    }

    if (!mounted) return;

    final selectedSupplier = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return BlocBuilder<SuppliersCubit, SuppliersState>(
              builder: (context, state) {
                if (state is SuppliersLoading) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
                }
                
                final suppliers = state is SuppliersLoaded ? state.suppliers : [];

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.selectContact,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: AppTheme.primaryColor),
                            onPressed: () async {
                              final cubit = context.read<SuppliersCubit>();
                              final newSupplier = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const EditSupplierScreen()),
                              );
                              if (newSupplier != null) {
                                await cubit.addSupplier(newSupplier);
                                if (!context.mounted) return;
                                Navigator.pop(context, newSupplier.name);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: suppliers.isEmpty
                          ? Center(child: Text(l10n.noSalesYet.replaceFirst('sales', 'contacts').replaceFirst('recorded', 'added')))
                          : ListView.builder(
                              controller: scrollController,
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
                                  onTap: () => Navigator.pop(context, supplier.name),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );

    if (selectedSupplier != null) {
      setState(() {
        _supplierController.text = selectedSupplier;
      });
    }
  }

  void _saveProduct() {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.productName} ${l10n.isRequired}')),
      );
      return;
    }

    final price = double.tryParse(_priceController.text.trim()) ?? 0;
    final stock = double.tryParse(_stockController.text.trim()) ?? 0;
    final lowStock = int.tryParse(_lowStockController.text.trim()) ?? 0;
    final barcode = _barcodeController.text.trim().isEmpty ? null : _barcodeController.text.trim();
    final supplier = _supplierController.text.trim().isEmpty ? null : _supplierController.text.trim();

    if (widget.product == null) {
      final newProduct = Product(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        unit: _selectedUnit,
        price: price,
        quantity: stock,
        lowStockThreshold: lowStock,
        barcode: barcode,
        supplierContact: supplier,
        expiryDate: _expiryDate,
        imagePath: _imagePath,
      );
      context.read<InventoryCubit>().addProduct(newProduct);
    } else {
      final updated = widget.product!.copyWith(
        name: name,
        unit: _selectedUnit,
        price: price,
        quantity: stock,
        lowStockThreshold: lowStock,
        barcode: barcode,
        supplierContact: supplier,
        expiryDate: _expiryDate,
        imagePath: _imagePath,
      );
      context.read<InventoryCubit>().updateProduct(updated);
    }

    Navigator.pop(context);
  }

  void _deleteProduct() {
    final product = widget.product;
    if (product == null) {
      Navigator.pop(context);
      return;
    }
    context.read<InventoryCubit>().deleteProduct(product.id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TouchableOpacity(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: AppTheme.textPrimary, size: 24),
                  ),
                  Expanded(
                    child: Text(
                      widget.isNew ? l10n.addProduct : l10n.editProduct,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (!widget.isNew)
                    TouchableOpacity(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(l10n.delete),
                            content: Text(l10n.confirmDelete),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(l10n.cancel, style: const TextStyle(color: AppTheme.textSecondary)),
                              ),
                              TextButton(
                                onPressed: () => _deleteProduct(),
                                child: Text(
                                  l10n.delete,
                                  style: const TextStyle(color: AppTheme.errorColor),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Icon(Icons.delete_outline, color: AppTheme.errorColor, size: 24),
                    )
                  else
                    const SizedBox(width: 48), // Placeholder to balance the title centering
                ],
              ),
              const SizedBox(height: 24),
              Center(
              child: TouchableOpacity(
                onTap: _pickImage,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(20),
                    image: _imagePath != null
                        ? DecorationImage(
                            image: FileImage(File(_imagePath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _imagePath == null
                      ? const Icon(
                          Icons.add_a_photo,
                          size: 40,
                          color: AppTheme.textSecondary,
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (_imagePath == null)
              Center(child: Text('${l10n.pickImage} ${l10n.optional}', style: const TextStyle(color: AppTheme.textSecondary))),
            const SizedBox(height: 32),
            _buildLabel('${l10n.productName} *'),
            const SizedBox(height: 8),
            _buildTextField(_nameController),
            const SizedBox(height: 24),
            _buildLabel(l10n.barcode),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildTextField(_barcodeController)),
                const SizedBox(width: 8),
                TouchableOpacity(
                  onTap: _scanBarcode,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.qr_code_scanner, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildLabel('${l10n.sellingPrice} (MMK) *'),
            const SizedBox(height: 8),
            _buildTextField(
              _priceController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(l10n.currentStock),
                      const SizedBox(height: 8),
                      _buildTextField(
                        _stockController,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(l10n.unit),
                      const SizedBox(height: 8),
                      Row(
                        children: _units.map((unit) {
                          final isSelected = _selectedUnit == unit;
                          return Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: TouchableOpacity(
                                onTap: () {
                                  setState(() {
                                    _selectedUnit = unit;
                                  });
                                },
                                child: Container(
                                  height: 50,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.primaryColor
                                        : AppTheme.surfaceColor,
                                    border: isSelected ? null : Border.all(color: AppTheme.borderColor),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    unit,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : AppTheme.textPrimary,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildLabel(l10n.lowStockThreshold),
            const SizedBox(height: 8),
            _buildTextField(
              _lowStockController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.lowStockAlertHelp,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 24),
            _buildLabel(l10n.expiryDate),
            const SizedBox(height: 8),
            TouchableOpacity(
              onTap: _pickExpiryDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 20, color: Colors.grey[600]),
                    const SizedBox(width: 12),
                    Text(
                      _expiryDate != null
                          ? DateFormat('dd MMM yyyy').format(_expiryDate!)
                          : l10n.selectExpiryDate,
                      style: TextStyle(
                        color: _expiryDate != null ? Colors.black87 : Colors.grey[500],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildLabel(l10n.supplierContact),
            const SizedBox(height: 8),
            _buildTextField(
              _supplierController, 
              keyboardType: TextInputType.phone,
              hintText: l10n.optional,
              readOnly: true,
              onTap: _selectSupplier,
            ),
            const SizedBox(height: 40),
            TouchableOpacity(
              onTap: _saveProduct,
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.save_outlined, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      widget.isNew ? l10n.addProduct : l10n.update,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 14,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    TextInputType? keyboardType,
    String? hintText,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppTheme.surfaceColor,
        hintText: hintText,
        hintStyle: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
