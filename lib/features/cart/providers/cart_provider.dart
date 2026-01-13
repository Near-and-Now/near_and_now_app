import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/cart_item_model.dart';
import '../../../core/models/product_model.dart';
import '../../../core/config/app_config.dart';

// Cart provider
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

// Cart total provider
final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0.0, (sum, item) => sum + item.totalPrice);
});

// Cart count provider
final cartCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.quantity);
});

// Delivery fee provider
final deliveryFeeProvider = Provider<double>((ref) {
  final total = ref.watch(cartTotalProvider);
  return total >= AppConfig.freeDeliveryThreshold ? 0.0 : AppConfig.deliveryFee;
});

// Grand total provider (subtotal + delivery fee)
final grandTotalProvider = Provider<double>((ref) {
  final subtotal = ref.watch(cartTotalProvider);
  final deliveryFee = ref.watch(deliveryFeeProvider);
  return subtotal + deliveryFee;
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]) {
    _loadCart();
  }

  static const String _cartKey = 'cart_items';

  // Load cart from local storage
  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartKey);

      if (cartJson != null) {
        final List<dynamic> cartList = jsonDecode(cartJson);
        state = cartList.map((item) => CartItem.fromJson(item)).toList();
        print('✅ Cart loaded: ${state.length} items');
      }
    } catch (error) {
      print('❌ Error loading cart: $error');
    }
  }

  // Save cart to local storage
  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = jsonEncode(state.map((item) => item.toJson()).toList());
      await prefs.setString(_cartKey, cartJson);
      print('✅ Cart saved: ${state.length} items');
    } catch (error) {
      print('❌ Error saving cart: $error');
    }
  }

  // Add item to cart
  void addItem(Product product, {int quantity = 1, double? customWeight}) {
    final existingIndex = state.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      // Update quantity if item already exists
      final updatedItem = state[existingIndex].copyWith(
        quantity: state[existingIndex].quantity + quantity,
        customWeight: customWeight ?? state[existingIndex].customWeight,
      );
      state = [
        ...state.sublist(0, existingIndex),
        updatedItem,
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      // Add new item
      state = [
        ...state,
        CartItem(
          product: product,
          quantity: quantity,
          customWeight: customWeight,
        ),
      ];
    }

    _saveCart();
  }

  // Remove item from cart
  void removeItem(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
    _saveCart();
  }

  // Update item quantity
  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }

    final index = state.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      final updatedItem = state[index].copyWith(quantity: quantity);
      state = [
        ...state.sublist(0, index),
        updatedItem,
        ...state.sublist(index + 1),
      ];
      _saveCart();
    }
  }

  // Update custom weight for loose items
  void updateWeight(String productId, double weight) {
    final index = state.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      final updatedItem = state[index].copyWith(customWeight: weight);
      state = [
        ...state.sublist(0, index),
        updatedItem,
        ...state.sublist(index + 1),
      ];
      _saveCart();
    }
  }

  // Clear cart
  void clearCart() {
    state = [];
    _saveCart();
  }

  // Check if product is in cart
  bool isInCart(String productId) {
    return state.any((item) => item.product.id == productId);
  }

  // Get item quantity
  int getQuantity(String productId) {
    final item = state.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(product: Product(
        id: '',
        name: '',
        price: 0,
        category: '',
        inStock: false,
      ), quantity: 0),
    );
    return item.quantity;
  }
}

