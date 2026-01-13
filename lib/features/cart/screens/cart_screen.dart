import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/utils/formatters.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_card.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final subtotal = ref.watch(cartTotalProvider);
    final deliveryFee = ref.watch(deliveryFeeProvider);
    final grandTotal = ref.watch(grandTotalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          if (cartItems.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear Cart'),
                    content: const Text(
                      'Are you sure you want to remove all items from your cart?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(cartProvider.notifier).clearCart();
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Clear',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Clear'),
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              message: 'Add some products to your cart and they will appear here',
              actionText: 'Start Shopping',
              onAction: () => context.go('/shop'),
            )
          : Column(
              children: [
                // Cart items list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      return CartItemCard(
                        cartItem: cartItems[index],
                        onRemove: () {
                          ref
                              .read(cartProvider.notifier)
                              .removeItem(cartItems[index].product.id);
                        },
                        onQuantityChanged: (quantity) {
                          ref
                              .read(cartProvider.notifier)
                              .updateQuantity(
                                cartItems[index].product.id,
                                quantity,
                              );
                        },
                      );
                    },
                  ),
                ),
                
                // Cart summary
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
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              Formatters.formatCurrency(subtotal),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Delivery Fee',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              deliveryFee == 0
                                  ? 'FREE'
                                  : Formatters.formatCurrency(deliveryFee),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: deliveryFee == 0
                                    ? AppColors.success
                                    : AppColors.textPrimary,
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
                              Formatters.formatCurrency(grandTotal),
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
                          text: 'Proceed to Checkout',
                          onPressed: () => context.push('/checkout'),
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
}

