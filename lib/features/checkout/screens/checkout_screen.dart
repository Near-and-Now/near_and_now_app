import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/widgets/location_picker_sheet.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/models/order_model.dart';
import '../../../core/models/product_model.dart';
import '../../../core/models/cart_item_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../products/providers/products_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String? _selectedAddress;
  String _paymentMethod = 'COD';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSelectedAddress();
  }

  Future<void> _loadSelectedAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final address = prefs.getString('manual_location_address');
    if (mounted && address != null) {
      setState(() {
        _selectedAddress = address;
      });
    }
  }

  Future<void> _placeOrder() async {
    if (_selectedAddress == null || _selectedAddress!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a delivery address'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final cartItems = ref.read(cartProvider);
      final subtotal = ref.read(cartTotalProvider);
      final deliveryFee = ref.read(deliveryFeeProvider);
      final total = ref.read(grandTotalProvider);
      final user = await ref.read(authServiceProvider).getCurrentUser();

      if (user == null) {
        throw Exception('Please login to place order');
      }

      // Create order items
      final orderItems = cartItems.map((item) {
        return OrderItem(
          productId: item.product.id,
          name: item.product.name,
          price: item.product.price,
          quantity: item.quantity,
          image: item.product.displayImage,
        );
      }).toList();

      // Create shipping address from selected address
      final addressParts = _selectedAddress!.split(',');
      final shippingAddress = ShippingAddress(
        address: _selectedAddress!,
        city: addressParts.length > 1 ? addressParts[addressParts.length - 2].trim() : 'Unknown',
        state: addressParts.length > 2 ? addressParts[addressParts.length - 1].trim() : 'Unknown',
        pincode: '000000',
      );

      // For UPI/Card payments, show payment gateway first
      if (_paymentMethod != 'COD') {
        setState(() {
          _isLoading = false;
        });

        final paymentSuccess = await _showPaymentGateway(total);

        if (!paymentSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment cancelled'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }

        setState(() {
          _isLoading = true;
        });
      }

      // Create order with pending status for all payment methods
      // Payment status will be updated after successful payment
      final order = await SupabaseService().createOrder(
        userId: user.id,
        customerName: user.name ?? 'Guest',
        customerEmail: user.email ?? '',
        customerPhone: user.phone ?? '',
        orderStatus: OrderStatus.placed,
        paymentStatus: PaymentStatus.pending,
        paymentMethod: _paymentMethod,
        orderTotal: total,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        items: orderItems,
        shippingAddress: shippingAddress,
      );

      // Clear cart
      ref.read(cartProvider.notifier).clearCart();

      if (mounted) {
        context.go('/thank-you/${order.id}');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: $error'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<bool> _showPaymentGateway(double amount) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _PaymentGatewayDialog(
        amount: amount,
        paymentMethod: _paymentMethod,
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final subtotal = ref.watch(cartTotalProvider);
    final deliveryFee = ref.watch(deliveryFeeProvider);
    final total = ref.watch(grandTotalProvider);
    
    // Get categories from cart items for related product recommendations
    final cartCategories = cartItems
        .map((item) => item.product.category)
        .toSet()
        .toList();
    
    final suggestedProductsAsync = ref.watch(relatedProductsProvider(cartCategories));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF8F8F8),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section 1: Delivery Location
                  _buildDeliveryLocationSection(),

                  const SizedBox(height: 8),

                  // Section 2: Cart Items
                  _buildCartItemsSection(cartItems),

                  const SizedBox(height: 8),

                  // Payment Method
                  _buildPaymentMethodSection(),

                  const SizedBox(height: 8),

                  // Section 3: Suggested Products
                  suggestedProductsAsync.when(
                    data: (products) => _buildSuggestedProductsSection(products),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // Bottom: Order Summary & Place Order Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [AppColors.shadowLg],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Subtotal',
                        style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                      ),
                      Text(
                        Formatters.formatCurrency(subtotal),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Delivery Fee',
                        style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                      ),
                      Text(
                        deliveryFee == 0 ? 'FREE' : Formatters.formatCurrency(deliveryFee),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: deliveryFee == 0 ? AppColors.success : null,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        Formatters.formatCurrency(total),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Place Order',
                    onPressed: _placeOrder,
                    isLoading: _isLoading,
                    fullWidth: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryLocationSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Delivery Location',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              showLocationPicker(
                context: context,
                onLocationSelect: (location) async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('manual_location_address', location.address);
                  await prefs.setDouble('manual_location_lat', location.lat);
                  await prefs.setDouble('manual_location_lng', location.lng);

                  setState(() {
                    _selectedAddress = location.address;
                  });
                },
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFF8F8F8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Deliver to',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedAddress ?? 'Select delivery address',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _selectedAddress != null
                                ? AppColors.textPrimary
                                : AppColors.textTertiary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemsSection(List<CartItem> cartItems) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Cart Items (${cartItems.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...cartItems.map((item) => _buildCartItemCard(item)),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFFAFAFA),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 60,
              height: 60,
              color: const Color(0xFFF0F0F0),
              child: item.product.displayImage.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.product.displayImage,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => const Icon(Icons.image),
                      placeholder: (_, __) => const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  : const Icon(Icons.image),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item.product.unit ?? '1 unit',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatters.formatCurrency(item.product.price),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Qty: ${item.quantity}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.payment,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Payment Method',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildModernPaymentOption(
            value: 'COD',
            title: 'Cash on Delivery',
            subtitle: 'Pay when you receive',
            icon: Icons.money,
            gradient: const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
            ),
          ),
          const SizedBox(height: 12),
          _buildModernPaymentOption(
            value: 'UPI',
            title: 'UPI Payment',
            subtitle: 'Google Pay, PhonePe, Paytm',
            icon: Icons.qr_code_scanner,
            gradient: const LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF42A5F5)],
            ),
          ),
          const SizedBox(height: 12),
          _buildModernPaymentOption(
            value: 'Card',
            title: 'Credit/Debit Card',
            subtitle: 'Visa, Mastercard, Rupay',
            icon: Icons.credit_card,
            gradient: const LinearGradient(
              colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedProductsSection(List<Product> allProducts) {
    final cartItems = ref.watch(cartProvider);
    final cartProductIds = cartItems.map((item) => item.product.id).toSet();
    
    // Filter out products already in cart and get up to 10 suggestions
    final suggested = allProducts
        .where((product) => !cartProductIds.contains(product.id))
        .take(10)
        .toList();

    if (suggested.isEmpty) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.recommend,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'You May Also Like',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: suggested.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 160,
                  margin: EdgeInsets.only(
                    right: index < suggested.length - 1 ? 12 : 0,
                  ),
                  child: ProductCard(product: suggested[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildModernPaymentOption({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
  }) {
    final isSelected = _paymentMethod == value;

    return InkWell(
      onTap: () {
        setState(() {
          _paymentMethod = value;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.05),
                    AppColors.primary.withOpacity(0.02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.white,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Icon with gradient background
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: gradient.colors.first.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// Payment Gateway Dialog Widget
class _PaymentGatewayDialog extends StatefulWidget {
  final double amount;
  final String paymentMethod;

  const _PaymentGatewayDialog({
    required this.amount,
    required this.paymentMethod,
  });

  @override
  State<_PaymentGatewayDialog> createState() => _PaymentGatewayDialogState();
}

class _PaymentGatewayDialogState extends State<_PaymentGatewayDialog> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              AppColors.primary.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Payment Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.paymentMethod == 'UPI'
                      ? [const Color(0xFF2196F3), const Color(0xFF42A5F5)]
                      : [const Color(0xFF9C27B0), const Color(0xFFBA68C8)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (widget.paymentMethod == 'UPI'
                            ? const Color(0xFF2196F3)
                            : const Color(0xFF9C27B0))
                        .withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                widget.paymentMethod == 'UPI'
                    ? Icons.qr_code_scanner
                    : Icons.credit_card,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              widget.paymentMethod == 'UPI' ? 'UPI Payment' : 'Card Payment',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // Amount
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                Formatters.formatCurrency(widget.amount),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Payment Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  if (widget.paymentMethod == 'UPI') ...[
                    const Icon(Icons.qr_code_2, size: 120, color: AppColors.textSecondary),
                    const SizedBox(height: 12),
                    const Text(
                      'Scan QR code with any UPI app',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Google Pay • PhonePe • Paytm',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ] else ...[
                    const Icon(Icons.credit_card, size: 60, color: AppColors.textSecondary),
                    const SizedBox(height: 12),
                    const Text(
                      'Enter your card details',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Visa • Mastercard • Rupay',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            if (_isProcessing)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text(
                    'Processing payment...',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _processPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Pay Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      // In a real app, you would integrate with actual payment gateway here
      // For now, we'll simulate a successful payment
      Navigator.of(context).pop(true);
    }
  }
}

