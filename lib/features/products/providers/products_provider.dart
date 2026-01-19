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

// Simple related products provider - shows products from same categories as cart items
// This uses the already-loaded products instead of fetching again
final relatedProductsProvider = Provider.family<List<Product>, List<String>>(
  (ref, cartCategories) {
    print('🎯 relatedProductsProvider called');
    print('📂 Cart categories: $cartCategories');
    
    // Get the already-loaded products (synchronously from cache)
    final allProductsAsync = ref.watch(_rawProductsProvider);
    
    // If still loading, return empty list
    if (!allProductsAsync.hasValue) {
      print('⏳ Products still loading...');
      return [];
    }
    
    final allProducts = allProductsAsync.value ?? [];
    print('📦 Total products available: ${allProducts.length}');
    
    // If cart is empty, return first 10 products
    if (cartCategories.isEmpty) {
      print('⚠️ Cart is empty, returning first 10 products');
      final result = allProducts.take(10).toList();
      print('✅ Returning ${result.length} products');
      return result;
    }
    
    // Filter products from same categories as cart items
    final relatedProducts = allProducts
        .where((product) => cartCategories.contains(product.category) && product.inStock)
        .toList();
    
    print('🔍 Found ${relatedProducts.length} products in cart categories');
    
    // Shuffle for variety
    relatedProducts.shuffle(Random());
    
    // If we have enough products from same categories, return them
    if (relatedProducts.length >= 10) {
      final result = relatedProducts.take(10).toList();
      print('✅ Returning ${result.length} products from cart categories');
      return result;
    }
    
    // Otherwise, add more products from other categories to reach 10
    final otherProducts = allProducts
        .where((product) => !cartCategories.contains(product.category) && product.inStock)
        .toList();
    otherProducts.shuffle(Random());
    
    final result = [
      ...relatedProducts,
      ...otherProducts.take(10 - relatedProducts.length),
    ];
    
    print('✅ Returning ${result.length} products (${relatedProducts.length} from cart categories + ${result.length - relatedProducts.length} others)');
    return result;
  },
);