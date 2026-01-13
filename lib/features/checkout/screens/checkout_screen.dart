import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/models/order_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  
  String _paymentMethod = 'COD';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final user = await ref.read(authServiceProvider).getCurrentUser();
    if (user != null) {
      _nameController.text = user.name ?? '';
      _phoneController.text = user.phone ?? '';
      _emailController.text = user.email ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final cartItems = ref.read(cartProvider);
      final subtotal = ref.read(cartTotalProvider);
      final deliveryFee = ref.read(deliveryFeeProvider);
      final total = ref.read(grandTotalProvider);
      final user = await ref.read(authServiceProvider).getCurrentUser();

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

      // Create shipping address
      final shippingAddress = ShippingAddress(
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        pincode: _pincodeController.text.trim(),
      );

      // Create order
      final order = await SupabaseService().createOrder(
        userId: user?.id,
        customerName: _nameController.text.trim(),
        customerEmail: _emailController.text.trim(),
        customerPhone: _phoneController.text.trim(),
        orderStatus: OrderStatus.placed,
        paymentStatus: _paymentMethod == 'COD'
            ? PaymentStatus.pending
            : PaymentStatus.paid,
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

  @override
  Widget build(BuildContext context) {
    final subtotal = ref.watch(cartTotalProvider);
    final deliveryFee = ref.watch(deliveryFeeProvider);
    final total = ref.watch(grandTotalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Contact Information
                    _buildSectionTitle('Contact Information'),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Full Name',
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Phone Number',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Email (Optional)',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Delivery Address
                    _buildSectionTitle('Delivery Address'),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Address',
                      controller: _addressController,
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'City',
                      controller: _cityController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your city';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'State',
                      controller: _stateController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your state';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Pincode',
                      controller: _pincodeController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your pincode';
                        }
                        if (value.length != 6) {
                          return 'Pincode must be 6 digits';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Payment Method
                    _buildSectionTitle('Payment Method'),
                    const SizedBox(height: 16),
                    _buildPaymentOption('COD', 'Cash on Delivery'),
                    _buildPaymentOption('UPI', 'UPI Payment'),
                    _buildPaymentOption('Card', 'Credit/Debit Card'),
                  ],
                ),
              ),
            ),
            
            // Order Summary & Place Order Button
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

  Widget _buildPaymentOption(String value, String label) {
    return RadioListTile<String>(
      value: value,
      groupValue: _paymentMethod,
      onChanged: (newValue) {
        setState(() {
          _paymentMethod = newValue!;
        });
      },
      title: Text(label),
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
    );
  }
}

