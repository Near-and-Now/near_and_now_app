import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/product_model.dart';
import '../../../core/services/supabase_service.dart';

// Products service provider
final productsServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

// All products provider
final allProductsProvider = FutureProvider<List<Product>>((ref) async {
  final service = ref.read(productsServiceProvider);
  return await service.getAllProducts();
});

// Products by category provider
final productsByCategoryProvider =
    FutureProvider.family<List<Product>, String>((ref, category) async {
  final service = ref.read(productsServiceProvider);
  return await service.getProductsByCategory(category);
});

// Search products provider
final searchProductsProvider =
    FutureProvider.family<List<Product>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final service = ref.read(productsServiceProvider);
  return await service.searchProducts(query);
});

// Single product provider
final productByIdProvider =
    FutureProvider.family<Product?, String>((ref, productId) async {
  final service = ref.read(productsServiceProvider);
  return await service.getProductById(productId);
});

// Categories provider (derived from all products)
final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final productsAsync = ref.watch(allProductsProvider);
  return productsAsync.when(
    data: (products) {
      final categories = products.map((p) => p.category).toSet().toList();
      categories.sort();
      return categories;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

