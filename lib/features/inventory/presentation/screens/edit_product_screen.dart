import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:inventory_management_app/data/datasources/local/database.dart' as db;
import 'package:inventory_management_app/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:inventory_management_app/features/suppliers/presentation/providers/suppliers_providers.dart';
import 'package:path/path.dart' as path;

class EditProductScreen extends ConsumerStatefulWidget {
  final db.Product product;

  const EditProductScreen({super.key, required this.product});

  @override
  ConsumerState<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends ConsumerState<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _skuController;
  late TextEditingController _barcodeController;
  late TextEditingController _quantityController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _locationController;
  late TextEditingController _minStockController;
  late TextEditingController _costController;
  late TextEditingController _priceController;
  String? _selectedSupplierId;

  // New state variables for attachments
  late List<String> _imagePaths;
  late List<String> _documentPaths;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _skuController = TextEditingController(text: widget.product.sku);
    _barcodeController = TextEditingController(text: widget.product.barcode);
    _quantityController =
        TextEditingController(text: widget.product.stockQuantity.toString());
    _descriptionController =
        TextEditingController(text: widget.product.description);
    _categoryController = TextEditingController(text: widget.product.category);
    _locationController = TextEditingController(text: widget.product.location);
    _minStockController = TextEditingController(
        text: widget.product.minimumStockThreshold?.toString());
    _costController =
        TextEditingController(text: widget.product.cost?.toString());
    _priceController =
        TextEditingController(text: widget.product.sellingPrice?.toString());
    _selectedSupplierId = widget.product.supplierId;

    // Initialize attachment paths from the product
    _imagePaths = List<String>.from(widget.product.imageUrls ?? []);
    _documentPaths = List<String>.from(widget.product.documentUrls ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _locationController.dispose();
    _minStockController.dispose();
    _costController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    final code = await context.push<String>('/scanner');
    if (code != null) {
      setState(() {
        _barcodeController.text = code;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePaths.add(pickedFile.path);
      });
    }
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        _documentPaths.add(result.files.single.path!);
      });
    }
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      final barcodeText = _barcodeController.text;
      final descriptionText = _descriptionController.text;
      final categoryText = _categoryController.text;
      final locationText = _locationController.text;

      final updatedProduct = widget.product.copyWith(
        name: _nameController.text,
        sku: _skuController.text,
        stockQuantity: int.tryParse(_quantityController.text) ?? 0,
        barcode: Value(barcodeText.isEmpty ? null : barcodeText),
        description: Value(descriptionText.isEmpty ? null : descriptionText),
        category: Value(categoryText.isEmpty ? null : categoryText),
        location: Value(locationText.isEmpty ? null : locationText),
        supplierId: Value(_selectedSupplierId),
        minimumStockThreshold: Value(int.tryParse(_minStockController.text)),
        cost: Value(double.tryParse(_costController.text)),
        sellingPrice: Value(double.tryParse(_priceController.text)),
        imageUrls: Value(_imagePaths),
        documentUrls: Value(_documentPaths),
      );

      try {
        await ref.read(productRepositoryProvider).updateProduct(updatedProduct);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product updated successfully')),
          );
          ref.invalidate(productDetailProvider(widget.product.id));
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating product: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final suppliersAsyncValue = ref.watch(supplierListStreamProvider(null));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateProduct,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Product Name', border: OutlineInputBorder()), validator: (v) => (v == null || v.isEmpty) ? 'Please enter a name' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _skuController, decoration: const InputDecoration(labelText: 'SKU', border: OutlineInputBorder()), validator: (v) => (v == null || v.isEmpty) ? 'Please enter a SKU' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _barcodeController, decoration: InputDecoration(labelText: 'Barcode (Optional)', border: const OutlineInputBorder(), suffixIcon: IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: _scanBarcode))),
              const SizedBox(height: 16),
              suppliersAsyncValue.when(
                data: (suppliers) => DropdownButtonFormField<String>(
                  value: _selectedSupplierId,
                  decoration: const InputDecoration(labelText: 'Supplier (Optional)', border: OutlineInputBorder()),
                  items: suppliers.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                  onChanged: (value) => setState(() => _selectedSupplierId = value),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => const Text('Could not load suppliers'),
              ),
              const SizedBox(height: 16),
              TextFormField(controller: _quantityController, decoration: const InputDecoration(labelText: 'Stock Quantity', border: OutlineInputBorder()), keyboardType: TextInputType.number, validator: (v) => (v == null || v.isEmpty || int.tryParse(v) == null) ? 'Enter a valid quantity' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Description (Optional)', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextFormField(controller: _categoryController, decoration: const InputDecoration(labelText: 'Category (Optional)', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextFormField(controller: _locationController, decoration: const InputDecoration(labelText: 'Location (Optional)', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextFormField(controller: _minStockController, decoration: const InputDecoration(labelText: 'Minimum Stock Threshold (Optional)', border: OutlineInputBorder()), keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              TextFormField(controller: _costController, decoration: const InputDecoration(labelText: 'Cost Price (Optional)', border: OutlineInputBorder()), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: 16),
              TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: 'Selling Price (Optional)', border: OutlineInputBorder()), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: 24),
              Text('Attachments', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Text('Images (${_imagePaths.length})')),
                  OutlinedButton.icon(onPressed: _pickImage, icon: const Icon(Icons.add_photo_alternate_outlined), label: const Text('Add Image')),
                ],
              ),
              _buildImagePreview(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: Text('Documents (${_documentPaths.length})')),
                  OutlinedButton.icon(onPressed: _pickDocument, icon: const Icon(Icons.attach_file), label: const Text('Add Document')),
                ],
              ),
              _buildDocumentList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_imagePaths.isEmpty) return const SizedBox.shrink();
    return Container(
      height: 100,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _imagePaths.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Stack(
              children: [
                Image.file(File(_imagePaths[index]), height: 100, width: 100, fit: BoxFit.cover),
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => setState(() => _imagePaths.removeAt(index)),
                    child: const CircleAvatar(radius: 12, backgroundColor: Colors.black54, child: Icon(Icons.close, color: Colors.white, size: 16)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDocumentList() {
    if (_documentPaths.isEmpty) return const SizedBox.shrink();
    return Column(
      children: _documentPaths.map((docPath) {
        return Card(
          margin: const EdgeInsets.only(top: 8),
          child: ListTile(
            leading: const Icon(Icons.description),
            title: Text(path.basename(docPath), overflow: TextOverflow.ellipsis),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => setState(() => _documentPaths.remove(docPath)),
            ),
          ),
        );
      }).toList(),
    );
  }
}