import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/utils/formatters.dart';
import '../providers/products_provider.dart';
import '../../cart/providers/cart_provider.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productByIdProvider(productId));
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
        ],
      ),
      body: productAsync.when(
        data: (product) {
          if (product == null) {
            return const ErrorView(message: 'Product not found');
          }

          final isInCart = cart.any((item) => item.product.id == product.id);
          final quantity = cart
              .firstWhere(
                (item) => item.product.id == product.id,
                orElse: () => cart.first,
              )
              .quantity;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                if (product.displayImage.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: product.displayImage,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 300,
                      color: AppColors.surfaceVariant,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 300,
                      color: AppColors.surfaceVariant,
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 80,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  )
                else
                  Container(
                    height: 300,
                    color: AppColors.surfaceVariant,
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 80,
                      color: AppColors.textTertiary,
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Category
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.badgeGreen,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          Formatters.formatCategoryName(product.category),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.badgeGreenText,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Price
                      Row(
                        children: [
                          Text(
                            Formatters.formatCurrency(product.price),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          if (product.hasDiscount) ...[
                            const SizedBox(width: 12),
                            Text(
                              Formatters.formatCurrency(product.originalPrice!),
                              style: const TextStyle(
                                fontSize: 18,
                                color: AppColors.textTertiary,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${product.discountPercentage?.toStringAsFixed(0)}% OFF',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Stock Status
                      Row(
                        children: [
                          Icon(
                            product.inStock ? Icons.check_circle : Icons.cancel,
                            color: product.inStock
                                ? AppColors.success
                                : AppColors.error,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            product.inStock ? 'In Stock' : 'Out of Stock',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: product.inStock
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Description
                      if (product.description != null &&
                          product.description!.isNotEmpty) ...[
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.description!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Product Details
                      if (product.weight != null || product.size != null) ...[
                        const Text(
                          'Product Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (product.weight != null)
                          _buildDetailRow('Weight', product.weight!),
                        if (product.size != null)
                          _buildDetailRow('Size', product.size!),
                        if (product.unit != null)
                          _buildDetailRow('Unit', product.unit!),
                        const SizedBox(height: 24),
                      ],

                      // Add to Cart Section
                      if (product.inStock)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              if (isInCart)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Quantity',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove),
                                          onPressed: () {
                                            ref
                                                .read(cartProvider.notifier)
                                                .updateQuantity(
                                                  product.id,
                                                  quantity - 1,
                                                );
                                          },
                                        ),
                                        Text(
                                          '$quantity',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: () {
                                            ref
                                                .read(cartProvider.notifier)
                                                .updateQuantity(
                                                  product.id,
                                                  quantity + 1,
                                                );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 16),
                              CustomButton(
                                text: isInCart
                                    ? 'Update Cart'
                                    : 'Add to Cart',
                                onPressed: () {
                                  if (!isInCart) {
                                    ref
                                        .read(cartProvider.notifier)
                                        .addItem(product);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            '${product.name} added to cart'),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                  }
                                },
                                fullWidth: true,
                                icon: isInCart
                                    ? Icons.check
                                    : Icons.shopping_cart,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading product...'),
        error: (error, stack) => ErrorView(
          message: 'Failed to load product',
          onRetry: () => ref.invalidate(productByIdProvider(productId)),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

