import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

class ProductApi {
  ProductApi({http.Client? client}) : _client = client ?? http.Client();

  static final Uri _productsUri = Uri.parse(
    'https://fakestoreapi.com/products/',
  );

  final http.Client _client;

  Future<List<Product>> fetchProducts() async {
    final response = await _client.get(_productsUri);
    _ensureSuccess(response);
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Product> createProduct(Product product) async {
    final response = await _client.post(
      _productsUri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson(includeId: false)),
    );
    _ensureSuccess(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return product.copyWith(
      id: data['id'] is num ? (data['id'] as num).toInt() : product.id,
    );
  }

  Future<Product> updateProduct(Product product) async {
    final response = await _client.put(
      _productUri(product.id),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson(includeId: false)),
    );
    _ensureSuccess(response);
    return product;
  }

  Future<void> deleteProduct(int id) async {
    final response = await _client.delete(_productUri(id));
    _ensureSuccess(response);
  }

  Uri _productUri(int id) => Uri.parse('${_productsUri.toString()}$id');

  void _ensureSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw http.ClientException(
        'La API respondió con el estado ${response.statusCode}.',
        response.request?.url,
      );
    }
  }
}
