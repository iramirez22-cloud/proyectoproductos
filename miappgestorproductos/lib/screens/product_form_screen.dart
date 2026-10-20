import 'package:flutter/material.dart';

import '../models/product.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.product});

  final Product? product;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _priceController;
  late final TextEditingController _categoryController;
  late final TextEditingController _imageController;
  late final TextEditingController _descriptionController;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _titleController = TextEditingController(text: product?.title ?? '');
    _priceController = TextEditingController(
      text: product == null ? '' : product.price.toString(),
    );
    _categoryController = TextEditingController(text: product?.category ?? '');
    _imageController = TextEditingController(text: product?.image ?? '');
    _descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _imageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _required(String? value, String label) {
    return value == null || value.trim().isEmpty ? 'Ingresa $label' : null;
  }

  String? _validatePrice(String? value) {
    final requiredError = _required(value, 'el precio');
    if (requiredError != null) return requiredError;
    final price = double.tryParse(value!.trim().replaceAll(',', '.'));
    if (price == null || price <= 0) return 'Ingresa un precio mayor que cero';
    return null;
  }

  String? _validateImage(String? value) {
    final requiredError = _required(value, 'la URL de la imagen');
    if (requiredError != null) return requiredError;
    final uri = Uri.tryParse(value!.trim());
    if (uri == null ||
        !uri.hasAuthority ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      return 'Ingresa una URL válida (http o https)';
    }
    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final previous = widget.product;
    Navigator.pop(
      context,
      Product(
        id: previous?.id ?? 0,
        title: _titleController.text.trim(),
        price: double.parse(_priceController.text.trim().replaceAll(',', '.')),
        category: _categoryController.text.trim(),
        image: _imageController.text.trim(),
        description: _descriptionController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar producto' : 'Nuevo producto'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Título',
                            prefixIcon: Icon(Icons.title),
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          validator: (value) => _required(value, 'el título'),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _priceController,
                          decoration: const InputDecoration(
                            labelText: 'Precio',
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: _validatePrice,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _categoryController,
                          decoration: const InputDecoration(
                            labelText: 'Categoría',
                            prefixIcon: Icon(Icons.category_outlined),
                          ),
                          validator: (value) =>
                              _required(value, 'la categoría'),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _imageController,
                          decoration: const InputDecoration(
                            labelText: 'URL de imagen',
                            prefixIcon: Icon(Icons.image_outlined),
                          ),
                          keyboardType: TextInputType.url,
                          validator: _validateImage,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Descripción',
                            prefixIcon: Icon(Icons.notes),
                            alignLabelWithHint: true,
                          ),
                          minLines: 3,
                          maxLines: 5,
                          textCapitalization: TextCapitalization.sentences,
                          validator: (value) =>
                              _required(value, 'la descripción'),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _save,
                            icon: const Icon(Icons.save_outlined),
                            label: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                _isEditing
                                    ? 'Guardar cambios'
                                    : 'Agregar producto',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
