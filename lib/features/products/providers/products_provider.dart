import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/product_model.dart';
import '../../../core/services/supabase_service.dart';

// Products service provider
final productsServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

// All products provider (unshuffled - for internal use)
final _rawProductsProvider = FutureProvider<List<Product>>((ref) async {
  final service = ref.read(productsServiceProvider);
  return await service.getAllProducts();
});

// All products provider (randomized on each app open/login)
final allProductsProvider = FutureProvider<List<Product>>((ref) async {
  final products = await ref.watch(_rawProductsProvider.future);
  // Shuffle products for variety on each app session
  final shuffled = List<Product>.from(products);
  shuffled.shuffle(Random());
  return shuffled;
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

// Categories provider with images from database
final categoriesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.read(productsServiceProvider);
  return await service.getAllCategories();
});

// Legacy categories provider (just names) - for backward compatibility
final categoryNamesProvider = FutureProvider<List<String>>((ref) async {
  final categoriesAsync = ref.watch(categoriesProvider);
  return categoriesAsync.when(
    data: (categories) {
      return categories.map((c) => c['name'] as String).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Related products provider based on cart items
// Returns products from the same categories as items in cart
final relatedProductsProvider = FutureProvider.family<List<Product>, List<String>>(
  (ref, cartCategories) async {
    if (cartCategories.isEmpty) {
      // If cart is empty, return random products
      return await ref.watch(allProductsProvider.future);
    }
    
    final allProducts = await ref.watch(_rawProductsProvider.future);
    
    // Filter products that match cart categories
    final relatedProducts = allProducts.where((product) {
      return cartCategories.contains(product.category);
    }).toList();
    
    // Shuffle for variety
    relatedProducts.shuffle(Random());
    
    // If we have enough related products, return them
    if (relatedProducts.length >= 10) {
      return relatedProducts.take(10).toList();
    }
    
    // Otherwise, supplement with random products
    final remaining = allProducts.where((product) {
      return !cartCategories.contains(product.category);
    }).toList();
    remaining.shuffle(Random());
    
    return [
      ...relatedProducts,
      ...remaining.take(10 - relatedProducts.length),
    ];
  },
);