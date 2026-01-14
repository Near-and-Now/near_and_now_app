import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/widgets/location_widget.dart';
import '../../../core/utils/formatters.dart';
import '../../products/providers/products_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(allProductsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // App Logo
            Image.asset(
              'assets/logo/Logo.png',
              height: 32,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to emoji if image fails
                return const Text('🏪', style: TextStyle(fontSize: 24));
              },
            ),
            const SizedBox(width: 10),
            const Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Near & Now',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, size: 24),
            onPressed: () => context.push('/search'),
            color: const Color(0xFF333333),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE8E8E8),
            height: 1,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(allProductsProvider);
          ref.invalidate(categoriesProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location widget
              const Padding(
                padding: EdgeInsets.all(16),
                child: LocationWidget(),
              ),
              
              // Header Banner
              _buildHeaderBanner(context),
              
              const SizedBox(height: 28),
              
              // Categories Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Shop by category',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF333333),
                        fontSize: 20,
                      ),
                ),
              ),
              const SizedBox(height: 16),
              
              categoriesAsync.when(
                data: (categories) => _buildCategoriesGrid(context, categories),
                loading: () => const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => const SizedBox(),
              ),
              
              const SizedBox(height: 32),
              
              // Featured Products Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Featured products',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF333333),
                            fontSize: 20,
                          ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/shop'),
                      child: Text(
                        'See all',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              productsAsync.when(
                data: (products) {
                  final featured = _getRotatedFeaturedProducts(products, 6);
                  return _buildProductsGrid(featured);
                },
                loading: () => const SizedBox(
                  height: 300,
                  child: LoadingIndicator(message: 'Loading products...'),
                ),
                error: (error, stack) => ErrorView(
                  message: 'Failed to load products',
                  onRetry: () => ref.invalidate(allProductsProvider),
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Fresh groceries delivered',
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'in minutes',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context.go('/shop'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary, width: 1.5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Shop now',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.shopping_basket_outlined,
              size: 36,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid(BuildContext context, List<Map<String, dynamic>> categories) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final categoryName = category['name'] as String;
          final imageUrl = category['image_url'] as String?;
          
          // Get category background color
          final bgColor = _getCategoryColor(index);
          
          return GestureDetector(
            onTap: () => context.push('/category/$categoryName'),
            child: Column(
              children: [
                // Category image container
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE8E8E8),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Center(
                                child: Icon(
                                  _getCategoryIcon(categoryName),
                                  size: 32,
                                  color: const Color(0xFF999999),
                                ),
                              ),
                              errorWidget: (context, url, error) => Icon(
                                _getCategoryIcon(categoryName),
                                size: 32,
                                color: const Color(0xFF999999),
                              ),
                            )
                          : Icon(
                              _getCategoryIcon(categoryName),
                              size: 32,
                              color: const Color(0xFF999999),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Category name
                Text(
                  Formatters.formatCategoryName(categoryName),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductsGrid(List products) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ProductCard(product: products[index]);
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('fruit')) return Icons.apple;
    if (lower.contains('vegetable')) return Icons.eco;
    if (lower.contains('dairy')) return Icons.local_drink;
    if (lower.contains('meat')) return Icons.lunch_dining;
    if (lower.contains('bakery') || lower.contains('bread')) return Icons.bakery_dining;
    if (lower.contains('snack')) return Icons.cookie;
    if (lower.contains('beverage')) return Icons.coffee;
    return Icons.shopping_bag;
  }

  /// Get rotated featured products based on daily seed
  /// This ensures all users see the same products each day, but they rotate daily
  List _getRotatedFeaturedProducts(List products, int count) {
    if (products.isEmpty) return [];
    if (products.length <= count) return products;

    // Create a copy to avoid modifying the original list
    final productsCopy = List.from(products);
    
    // Use day of year as seed for consistent daily rotation
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final seed = now.year * 1000 + dayOfYear;
    
    // Shuffle with the daily seed
    productsCopy.shuffle(Random(seed));
    
    return productsCopy.take(count).toList();
  }

  /// Get background color for categories based on index
  Color _getCategoryColor(int index) {
    final colors = [
      const Color(0xFFF5F5F5),
      const Color(0xFFFFF8E1),
      const Color(0xFFE8F5E9),
      const Color(0xFFE3F2FD),
      const Color(0xFFFCE4EC),
      const Color(0xFFF3E5F5),
      const Color(0xFFE0F2F1),
      const Color(0xFFFFF3E0),
    ];
    return colors[index % colors.length];
  }
}

