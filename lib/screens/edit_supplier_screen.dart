import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zyae/l10n/generated/app_localizations.dart';
import 'package:zyae/models/supplier.dart';
import 'package:zyae/theme/app_theme.dart';

import 'package:zyae/widgets/touchable_opacity.dart';

class EditSupplierScreen extends StatefulWidget {
  final Supplier? supplier;

  const EditSupplierScreen({super.key, this.supplier});

  @override
  State<EditSupplierScreen> createState() => _EditSupplierScreenState();
}

class _EditSupplierScreenState extends State<EditSupplierScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  String? _imagePath;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.supplier?.name ?? '');
    _phoneController = TextEditingController(text: widget.supplier?.phoneNumber ?? '');
    _imagePath = widget.supplier?.imagePath;
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
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
                      widget.supplier == null ? l10n.addContact : l10n.editContact,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    TouchableOpacity(
                      onTap: _save,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.save, color: AppTheme.primaryColor, size: 24),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TouchableOpacity(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.surfaceColor,
                    backgroundImage: _imagePath != null ? FileImage(File(_imagePath!)) : null,
                    child: _imagePath == null 
                      ? const Icon(Icons.add_a_photo, size: 40, color: AppTheme.textSecondary) 
                      : null,
                  ),
                ),
              if (_imagePath == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    l10n.pickImage,
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: l10n.name,
                  labelStyle: const TextStyle(color: AppTheme.textSecondary),
                  filled: true,
                  fillColor: AppTheme.surfaceColor,
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
                ),
                validator: (value) => value == null || value.isEmpty ? l10n.isRequired : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: l10n.phoneNumber,
                  labelStyle: const TextStyle(color: AppTheme.textSecondary),
                  filled: true,
                  fillColor: AppTheme.surfaceColor,
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
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final supplier = Supplier(
        id: widget.supplier?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        phoneNumber: _phoneController.text,
        imagePath: _imagePath,
      );
      Navigator.pop(context, supplier);
    }
  }
}

