import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import '../models/address_model.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Singleton pattern
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get client => _client;

  // ==================== CATEGORY SERVICES ====================

  /// Get all categories
  Future<List<Map<String, dynamic>>> getAllCategories() async {
    try {
      print('🔄 Fetching categories from Supabase...');

      // Fetch categories - removed is_active filter as it doesn't exist in existing table
      final response = await _client
          .from('categories')
          .select()
          .order('name', ascending: true);

      print('✅ Successfully fetched ${response.length} categories');
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      print('❌ Error in getAllCategories: $error');
      print('ℹ️ Returning empty categories list');
      return [];
    }
  }

  // ==================== PRODUCT SERVICES ====================

  /// Get all products
  Future<List<Product>> getAllProducts() async {
    try {
      print('🔄 Fetching products from Supabase...');

      // Fetch all products in batches
      List<dynamic> allProducts = [];
      int from = 0;
      const int batchSize = 1000;
      bool hasMore = true;

      while (hasMore) {
        final response = await _client
            .from('products')
            .select()
            .eq('in_stock', true)
            .order('created_at', ascending: false)
            .range(from, from + batchSize - 1);

        if (response.isNotEmpty) {
          allProducts.addAll(response);
          from += batchSize;
          hasMore = response.length == batchSize;
        } else {
          hasMore = false;
        }
      }

      print('✅ Successfully fetched ${allProducts.length} products');
      return allProducts.map((json) => Product.fromJson(json)).toList();
    } catch (error) {
      print('❌ Error in getAllProducts: $error');
      rethrow;
    }
  }

  /// Get products by category
  Future<List<Product>> getProductsByCategory(String categoryName) async {
    try {
      print('🔎 Fetching products for category: $categoryName');

      List<dynamic> allProducts = [];
      int from = 0;
      const int batchSize = 1000;
      bool hasMore = true;

      while (hasMore) {
        final response = await _client
            .from('products')
            .select()
            .eq('category', categoryName)
            .eq('in_stock', true)
            .order('rating', ascending: false)
            .range(from, from + batchSize - 1);

        if (response.isNotEmpty) {
          allProducts.addAll(response);
          from += batchSize;
          hasMore = response.length == batchSize;
        } else {
          hasMore = false;
        }
      }

      print('✅ Fetched ${allProducts.length} products for category');
      return allProducts.map((json) => Product.fromJson(json)).toList();
    } catch (error) {
      print('❌ Error in getProductsByCategory: $error');
      return [];
    }
  }

  /// Search products
  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await _client
          .from('products')
          .select()
          .eq('in_stock', true)
          .ilike('name', '%$query%');

      return (response as List).map((json) => Product.fromJson(json)).toList();
    } catch (error) {
      print('❌ Error in searchProducts: $error');
      return [];
    }
  }

  /// Get product by ID
  Future<Product?> getProductById(String productId) async {
    try {
      final response = await _client
          .from('products')
          .select()
          .eq('id', productId)
          .single();

      return Product.fromJson(response);
    } catch (error) {
      print('❌ Error in getProductById: $error');
      return null;
    }
  }

  // ==================== AUTHENTICATION SERVICES ====================

  /// Login with OTP
  Future<void> loginWithOTP(String phone) async {
    try {
      await _client.auth.signInWithOtp(phone: phone);
    } catch (error) {
      print('❌ Error sending OTP: $error');
      rethrow;
    }
  }

  /// Verify OTP
  Future<AuthResponse> verifyOTP(String phone, String token) async {
    try {
      final response = await _client.auth.verifyOTP(
        phone: phone,
        token: token,
        type: OtpType.sms,
      );
      return response;
    } catch (error) {
      print('❌ Error verifying OTP: $error');
      rethrow;
    }
  }

  /// Get current user
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      return UserModel(
        id: user.id,
        phone: user.phone,
        email: user.email,
        name: user.userMetadata?['name'] as String?,
      );
    } catch (error) {
      print('❌ Error getting current user: $error');
      return null;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } catch (error) {
      print('❌ Error logging out: $error');
      rethrow;
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _client.auth.currentUser != null;

  /// Get auth state changes stream
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // ==================== ORDER SERVICES ====================

  /// Create order
  Future<Order> createOrder({
    String? userId,
    required String customerName,
    String? customerEmail,
    required String customerPhone,
    required OrderStatus orderStatus,
    required PaymentStatus paymentStatus,
    required String paymentMethod,
    required double orderTotal,
    required double subtotal,
    required double deliveryFee,
    required List<OrderItem> items,
    required ShippingAddress shippingAddress,
  }) async {
    try {
      print('🛒 Creating order...');
      print('   Customer: $customerName');
      print('   Phone: $customerPhone');
      print('   Email: $customerEmail');
      print('   User ID: $userId');
      print('   Total: ₹$orderTotal');
      print('   Items: ${items.length}');

      // Generate order number
      final orderNumber = await _generateOrderNumber();
      print('📝 Generated order number: $orderNumber');

      final orderPayload = {
        'user_id': userId,
        'customer_name': customerName,
        'customer_email': customerEmail,
        'customer_phone': customerPhone,
        'order_status': orderStatus.name,
        'payment_status': paymentStatus.name,
        'payment_method': paymentMethod,
        'order_total': orderTotal,
        'subtotal': subtotal,
        'delivery_fee': deliveryFee,
        'items': items.map((item) => item.toJson()).toList(),
        'shipping_address': shippingAddress.toJson(),
        'order_number': orderNumber,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      print('💾 Inserting order into database...');
      final response = await _client
          .from('orders')
          .insert(orderPayload)
          .select()
          .single();

      final createdOrder = Order.fromJson(response);
      print('✅ Order created successfully!');
      print('   Order ID: ${createdOrder.id}');
      print('   Order Number: ${createdOrder.orderNumber}');
      print('   Stored with phone: ${createdOrder.customerPhone}');

      return createdOrder;
    } catch (error, stackTrace) {
      print('❌ Error in createOrder: $error');
      print('   Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Generate order number
  Future<String> _generateOrderNumber() async {
    try {
      final today = DateTime.now();
      final dateString =
          '${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}';
      final prefix = 'NN$dateString';

      final response = await _client.rpc('generate_next_order_number',
          params: {'date_prefix': prefix});

      return response as String;
    } catch (error) {
      print('❌ Error generating order number: $error');
      rethrow;
    }
  }

  /// Get user orders
  Future<List<Order>> getUserOrders({
    String? userId,
    String? userPhone,
    String? userEmail,
  }) async {
    try {
      print('📦 Fetching orders for user...');
      print('   User ID: $userId');
      print('   User Phone: $userPhone');
      print('   User Email: $userEmail');

      final Set<String> orderIds = {};
      final List<Order> allOrders = [];

      // Query by user_id
      if (userId != null && userId.isNotEmpty) {
        try {
          final response = await _client
              .from('orders')
              .select()
              .eq('user_id', userId)
              .order('created_at', ascending: false);

          print('   Found ${response.length} orders by user_id');

          for (var orderJson in response) {
            try {
              final order = Order.fromJson(orderJson);
              if (!orderIds.contains(order.id)) {
                orderIds.add(order.id);
                allOrders.add(order);
              }
            } catch (parseError) {
              print('   ⚠️ Error parsing order: $parseError');
            }
          }
        } catch (queryError) {
          print('   ⚠️ Error querying by user_id: $queryError');
        }
      }

      // Query by phone (try multiple formats)
      if (userPhone != null && userPhone.isNotEmpty) {
        // Try exact match first
        try {
          final response = await _client
              .from('orders')
              .select()
              .eq('customer_phone', userPhone)
              .order('created_at', ascending: false);

          print('   Found ${response.length} orders by phone (exact: $userPhone)');

          for (var orderJson in response) {
            try {
              final order = Order.fromJson(orderJson);
              if (!orderIds.contains(order.id)) {
                orderIds.add(order.id);
                allOrders.add(order);
              }
            } catch (parseError) {
              print('   ⚠️ Error parsing order: $parseError');
            }
          }
        } catch (queryError) {
          print('   ⚠️ Error querying by phone: $queryError');
        }

        // If phone has +91, also try without it
        if (userPhone.startsWith('+91')) {
          final phoneWithoutPrefix = userPhone.substring(3);
          try {
            final response = await _client
                .from('orders')
                .select()
                .eq('customer_phone', phoneWithoutPrefix)
                .order('created_at', ascending: false);

            print('   Found ${response.length} orders by phone (without +91: $phoneWithoutPrefix)');

            for (var orderJson in response) {
              try {
                final order = Order.fromJson(orderJson);
                if (!orderIds.contains(order.id)) {
                  orderIds.add(order.id);
                  allOrders.add(order);
                }
              } catch (parseError) {
                print('   ⚠️ Error parsing order: $parseError');
              }
            }
          } catch (queryError) {
            print('   ⚠️ Error querying by phone without prefix: $queryError');
          }
        }
        // If phone doesn't have +91, also try with it
        else if (!userPhone.startsWith('+')) {
          final phoneWithPrefix = '+91$userPhone';
          try {
            final response = await _client
                .from('orders')
                .select()
                .eq('customer_phone', phoneWithPrefix)
                .order('created_at', ascending: false);

            print('   Found ${response.length} orders by phone (with +91: $phoneWithPrefix)');

            for (var orderJson in response) {
              try {
                final order = Order.fromJson(orderJson);
                if (!orderIds.contains(order.id)) {
                  orderIds.add(order.id);
                  allOrders.add(order);
                }
              } catch (parseError) {
                print('   ⚠️ Error parsing order: $parseError');
              }
            }
          } catch (queryError) {
            print('   ⚠️ Error querying by phone with prefix: $queryError');
          }
        }
      }

      // Query by email
      if (userEmail != null && userEmail.isNotEmpty) {
        try {
          final response = await _client
              .from('orders')
              .select()
              .eq('customer_email', userEmail)
              .order('created_at', ascending: false);

          print('   Found ${response.length} orders by email');

          for (var orderJson in response) {
            try {
              final order = Order.fromJson(orderJson);
              if (!orderIds.contains(order.id)) {
                orderIds.add(order.id);
                allOrders.add(order);
              }
            } catch (parseError) {
              print('   ⚠️ Error parsing order: $parseError');
            }
          }
        } catch (queryError) {
          print('   ⚠️ Error querying by email: $queryError');
        }
      }

      // Sort by created_at descending
      allOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      print('✅ Fetched ${allOrders.length} total unique orders');
      return allOrders;
    } catch (error, stackTrace) {
      print('❌ Error in getUserOrders: $error');
      print('   Stack trace: $stackTrace');
      rethrow;
    }
  }

  // ==================== ADDRESS SERVICES ====================

  /// Get user addresses
  Future<List<Address>> getUserAddresses(String userId) async {
    try {
      print('📍 Fetching addresses for user: $userId');

      final response = await _client
          .from('addresses')
          .select()
          .eq('user_id', userId)
          .order('is_default', ascending: false)
          .order('created_at', ascending: false);

      print('✅ Fetched ${response.length} addresses');
      return (response as List).map((json) => Address.fromJson(json)).toList();
    } catch (error) {
      print('❌ Error in getUserAddresses: $error');
      rethrow;
    }
  }

  /// Create address
  Future<Address> createAddress({
    required String userId,
    required String name,
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String state,
    required String pincode,
    required String phone,
    required bool isDefault,
  }) async {
    try {
      print('📍 Creating new address...');

      // If this is default, unset all other default addresses
      if (isDefault) {
        await _client
            .from('addresses')
            .update({'is_default': false})
            .eq('user_id', userId);
      }

      final addressData = {
        'user_id': userId,
        'name': name,
        'address_line_1': addressLine1,
        'address_line_2': addressLine2,
        'city': city,
        'state': state,
        'pincode': pincode,
        'phone': phone,
        'is_default': isDefault,
      };

      final response =
          await _client.from('addresses').insert(addressData).select().single();

      print('✅ Address created successfully');
      return Address.fromJson(response);
    } catch (error) {
      print('❌ Error in createAddress: $error');
      rethrow;
    }
  }

  /// Update address
  Future<Address> updateAddress({
    required String addressId,
    required String userId,
    String? name,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? pincode,
    String? phone,
    bool? isDefault,
  }) async {
    try {
      print('📍 Updating address: $addressId');

      // If setting as default, unset all other default addresses
      if (isDefault == true) {
        await _client
            .from('addresses')
            .update({'is_default': false})
            .eq('user_id', userId)
            .neq('id', addressId);
      }

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updateData['name'] = name;
      if (addressLine1 != null) updateData['address_line_1'] = addressLine1;
      if (addressLine2 != null) updateData['address_line_2'] = addressLine2;
      if (city != null) updateData['city'] = city;
      if (state != null) updateData['state'] = state;
      if (pincode != null) updateData['pincode'] = pincode;
      if (phone != null) updateData['phone'] = phone;
      if (isDefault != null) updateData['is_default'] = isDefault;

      final response = await _client
          .from('addresses')
          .update(updateData)
          .eq('id', addressId)
          .eq('user_id', userId)
          .select()
          .single();

      print('✅ Address updated successfully');
      return Address.fromJson(response);
    } catch (error) {
      print('❌ Error in updateAddress: $error');
      rethrow;
    }
  }

  /// Add address (helper method that accepts a Map)
  Future<Address> addAddress(Map<String, dynamic> addressData) async {
    return await createAddress(
      userId: addressData['user_id'] as String,
      name: addressData['name'] as String,
      addressLine1: addressData['address_line1'] as String,
      addressLine2: addressData['address_line2'] as String?,
      city: addressData['city'] as String,
      state: addressData['state'] as String,
      pincode: addressData['pincode'] as String,
      phone: addressData['phone'] as String,
      isDefault: addressData['is_default'] as bool? ?? false,
    );
  }

  /// Delete address
  Future<void> deleteAddress(String addressId, String userId) async {
    try {
      print('📍 Deleting address: $addressId');

      await _client
          .from('addresses')
          .delete()
          .eq('id', addressId)
          .eq('user_id', userId);

      print('✅ Address deleted successfully');
    } catch (error) {
      print('❌ Error in deleteAddress: $error');
      rethrow;
    }
  }

  /// Set default address
  Future<Address> setDefaultAddress(String addressId, String userId) async {
    try {
      print('📍 Setting default address: $addressId');

      // Unset all other default addresses
      await _client
          .from('addresses')
          .update({'is_default': false}).eq('user_id', userId);

      // Set this address as default
      final response = await _client
          .from('addresses')
          .update({
            'is_default': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', addressId)
          .eq('user_id', userId)
          .select()
          .single();

      print('✅ Default address updated successfully');
      return Address.fromJson(response);
    } catch (error) {
      print('❌ Error in setDefaultAddress: $error');
      rethrow;
    }
  }

  // ==================== NEWSLETTER SERVICES ====================

  /// Subscribe to newsletter
  Future<void> subscribeToNewsletter(String email) async {
    try {
      print('📧 Subscribing email to newsletter: $email');

      // Validate email
      final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
      if (!emailRegex.hasMatch(email)) {
        throw Exception('Please enter a valid email address');
      }

      final emailLower = email.toLowerCase().trim();

      // Check if email already exists
      final existing = await _client
          .from('newsletter_subscriptions')
          .select()
          .eq('email', emailLower)
          .maybeSingle();

      if (existing != null) {
        // If already subscribed and active, return
        if (existing['is_active'] == true) {
          print('✅ Email already subscribed');
          return;
        }

        // If exists but inactive, reactivate it
        await _client
            .from('newsletter_subscriptions')
            .update({
              'is_active': true,
              'subscribed_at': DateTime.now().toIso8601String(),
            })
            .eq('email', emailLower);

        print('✅ Email resubscribed successfully');
        return;
      }

      // Create new subscription
      await _client.from('newsletter_subscriptions').insert({
        'email': emailLower,
        'is_active': true,
        'subscribed_at': DateTime.now().toIso8601String(),
      });

      print('✅ Successfully subscribed to newsletter');
    } catch (error) {
      print('❌ Error in subscribeToNewsletter: $error');
      rethrow;
    }
  }
}

