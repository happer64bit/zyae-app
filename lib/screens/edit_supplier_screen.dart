import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zyae/l10n/generated/app_localizations.dart';
import 'package:zyae/models/supplier.dart';

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
      appBar: AppBar(
        title: Text(widget.supplier == null ? l10n.addContact : l10n.editContact),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _save,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _imagePath != null ? FileImage(File(_imagePath!)) : null,
                  child: _imagePath == null ? const Icon(Icons.add_a_photo, size: 40) : null,
                ),
              ),
              if (_imagePath == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(l10n.pickImage),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.name,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? l10n.isRequired : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: l10n.phoneNumber,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
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
