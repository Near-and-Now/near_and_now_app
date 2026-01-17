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
        toolbarHeight: 64,
        title: Row(
          children: [
            // App Logo
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                'assets/logo/Logo.png',
                height: 24,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to emoji if image fails
                  return const Text('🏪', style: TextStyle(fontSize: 20));
                },
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Near & Now',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.notifications_outlined, size: 22),
            ),
            onPressed: () {
              // TODO: Navigate to notifications
            },
            color: const Color(0xFF1A1A1A),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFF0F0F0),
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
                padding: EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: LocationWidget(),
              ),
              
              // Search bar
              _buildSearchBar(context),
              
              const SizedBox(height: 24),
              
              // Categories Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Categories',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1A1A),
                            fontSize: 22,
                          ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/shop'),
                      child: const Text(
                        'View All',
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
                child: Text(
                  'Popular',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                        fontSize: 22,
                      ),
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

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => context.push('/search'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: Colors.grey[600],
                size: 22,
              ),
              const SizedBox(width: 12),
              Text(
                'Search products...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid(BuildContext context, List<Map<String, dynamic>> categories) {
    // Show only first 8 categories for cleaner look
    final displayCategories = categories.length > 8 ? categories.sublist(0, 8) : categories;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.78,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
        ),
        itemCount: displayCategories.length,
        itemBuilder: (context, index) {
          final category = displayCategories[index];
          final categoryName = category['name'] as String;
          final imageUrl = category['image_url'] as String?;
          
          // Get category background color
          final bgColor = _getCategoryColor(index);
          
          return GestureDetector(
            onTap: () => context.push('/category/$categoryName'),
            child: Column(
              children: [
                // Category image container with shadow
                Container(
                  width: double.infinity,
                  height: 72,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: bgColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(
                              child: Icon(
                                _getCategoryIcon(categoryName),
                                size: 36,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            errorWidget: (context, url, error) => Icon(
                              _getCategoryIcon(categoryName),
                              size: 36,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          )
                        : Icon(
                            _getCategoryIcon(categoryName),
                            size: 36,
                            color: Colors.white.withOpacity(0.8),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                // Category name
                Text(
                  Formatters.formatCategoryName(categoryName),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
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
          childAspectRatio: 0.72,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
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

  /// Get vibrant background color for categories based on index
  Color _getCategoryColor(int index) {
    final colors = [
      const Color(0xFFFFB3BA), // Soft Pink
      const Color(0xFFFFDFBA), // Peach
      const Color(0xFFFFFFBA), // Light Yellow
      const Color(0xFFBAFFC9), // Mint Green
      const Color(0xFFBAE1FF), // Sky Blue
      const Color(0xFFE7BAFF), // Lavender
      const Color(0xFFFFBAE3), // Rose
      const Color(0xFFBAFFD4), // Aqua
    ];
    return colors[index % colors.length];
  }
}

