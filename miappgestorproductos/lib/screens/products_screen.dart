import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/product_api.dart';
import 'product_detail_screen.dart';
import 'product_form_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key, required this.api, required this.onLogout});

  final ProductApi api;
  final VoidCallback onLogout;

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _searchController = TextEditingController();
  final List<Product> _products = [];
  bool _loading = true;
  String? _error;

  List<Product> get _visibleProducts {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _products;
    return _products
        .where(
          (product) =>
              product.title.toLowerCase().contains(query) ||
              product.category.toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final products = await widget.api.fetchProducts();
      if (!mounted) return;
      setState(() {
        _products
          ..clear()
          ..addAll(products);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo cargar el catálogo.\n$error';
        _loading = false;
      });
    }
  }

  Future<void> _addProduct() async {
    final draft = await Navigator.push<Product>(
      context,
      MaterialPageRoute(builder: (_) => const ProductFormScreen()),
    );
    if (draft == null || !mounted) return;
    try {
      final responseProduct = await widget.api.createProduct(draft);
      if (!mounted) return;
      final created =
          _products.any((product) => product.id == responseProduct.id)
          ? responseProduct.copyWith(
              id:
                  _products.fold<int>(
                    0,
                    (largest, product) =>
                        product.id > largest ? product.id : largest,
                  ) +
                  1,
            )
          : responseProduct;
      setState(() => _products.insert(0, created));
      _showMessage('Producto agregado correctamente.');
    } catch (error) {
      if (mounted) _showMessage('No se pudo agregar el producto: $error');
    }
  }

  Future<Product?> _editProduct(Product product) async {
    final changes = await Navigator.push<Product>(
      context,
      MaterialPageRoute(builder: (_) => ProductFormScreen(product: product)),
    );
    if (changes == null) return null;
    try {
      final updated = await widget.api.updateProduct(changes);
      if (!mounted) return null;
      setState(() {
        final index = _products.indexWhere((item) => item.id == product.id);
        if (index != -1) _products[index] = updated;
      });
      _showMessage('Producto actualizado correctamente.');
      return updated;
    } catch (error) {
      if (mounted) _showMessage('No se pudo actualizar el producto: $error');
      return null;
    }
  }

  Future<void> _deleteProduct(Product product) async {
    await widget.api.deleteProduct(product.id);
    if (!mounted) return;
    setState(() => _products.removeWhere((item) => item.id == product.id));
    _showMessage('Producto eliminado correctamente.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  Future<void> _openDetails(Product product) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
          product: product,
          onEdit: _editProduct,
          onDelete: _deleteProduct,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = _visibleProducts;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.storefront_rounded),
            SizedBox(width: 10),
            Text(
              'Tienda de Irving',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout),
          ),
          IconButton(
            tooltip: 'Actualizar catálogo',
            onPressed: _loading ? null : _loadProducts,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addProduct,
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6750D8), Color(0xFF9474F0)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6750D8).withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Encuentra algo increíble',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _loading
                                ? 'Preparando tu catálogo...'
                                : '${_products.length} productos para descubrir',
                            style: const TextStyle(
                              color: Color(0xFFE8E2FF),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.shopping_bag_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Buscar por título o categoría',
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Limpiar búsqueda',
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.close),
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
            Expanded(child: _buildContent(products)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(List<Product> products) {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 14),
            const Text('Cargando productos...'),
          ],
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 48),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadProducts,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }
    if (products.isEmpty) {
      return Center(
        child: Text(
          _products.isEmpty
              ? 'No hay productos para mostrar.'
              : 'No se encontraron productos.',
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1000
            ? 3
            : constraints.maxWidth >= 650
            ? 2
            : 1;
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            mainAxisExtent: columns == 1 ? 168 : 372,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) => _ProductCard(
            product: products[index],
            compact: columns == 1,
            onTap: () => _openDetails(products[index]),
          ),
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.compact,
    required this.onTap,
  });

  final Product product;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: compact
            ? Row(
                children: [
                  SizedBox(
                    width: 132,
                    height: double.infinity,
                    child: _productImage(),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: _productSummary(context, maxLines: 2),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(Icons.chevron_right),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 160,
                    child: _productImage(),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: _productSummary(context, maxLines: 2),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Color _categoryColor(String category) {
    final value = category.toLowerCase();
    if (value.contains('women')) return const Color(0xFFD9578B);
    if (value.contains('jewel')) return const Color(0xFFCF8B19);
    if (value.contains('elect')) return const Color(0xFF3282C4);
    return const Color(0xFF25A47A);
  }

  Widget _productImage() {
    final accent = _categoryColor(product.category);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent.withValues(alpha: 0.13), const Color(0xFFF8F7FC)],
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Stack(
        children: [
          Positioned(
            top: 5,
            right: 5,
            child: Icon(
              Icons.auto_awesome,
              size: 18,
              color: accent.withValues(alpha: 0.65),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Image.network(
                product.image,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.broken_image_outlined, size: 42),
                ),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: accent,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _productSummary(BuildContext context, {required int maxLines}) {
    final colors = Theme.of(context).colorScheme;
    final accent = _categoryColor(product.category);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            product.category.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 7),
        Text(
          product.title,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          product.description,
          maxLines: compact ? 1 : 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: colors.onSurfaceVariant, height: 1.35),
        ),
        const Spacer(),
        Row(
          children: [
            Expanded(
              child: Text(
                '\$${product.price.toStringAsFixed(2)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_rounded, size: 18, color: accent),
          ],
        ),
      ],
    );
  }
}
