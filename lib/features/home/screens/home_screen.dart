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
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Professional Sticky Header with Location and Search
          SliverAppBar(
            pinned: true,
            floating: true,
            snap: false,
            expandedHeight: 140,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                children: [
                  const SizedBox(height: 50), // Status bar spacer
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: LocationWidget(),
                  ),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(64),
              child: _buildSearchBar(context),
            ),
          ),

          SliverToBoxAdapter(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(allProductsProvider);
                ref.invalidate(categoriesProvider);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Promo Banner (Simulated for professional look)
                  _buildPromoBanner(),

                  const SizedBox(height: 24),

                  // Categories Section
                  _buildSectionHeader(
                    context,
                    title: 'Shop by Category',
                    onViewAll: () => context.go('/shop')
                  ),
                  const SizedBox(height: 16),

                  categoriesAsync.when(
                    data: (categories) => _buildCategoriesGrid(context, categories),
                    loading: () => const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    error: (error, _) => const SizedBox(),
                  ),

                  const SizedBox(height: 32),

                  // Featured Products Section
                  _buildSectionHeader(context, title: 'Trending Now'),
                  const SizedBox(height: 16),

                  productsAsync.when(
                    data: (products) {
                      final featured = _getRotatedFeaturedProducts(products, 6);
                      return _buildProductsGrid(featured);
                    },
                    loading: () => const SizedBox(
                      height: 300,
                      child: LoadingIndicator(message: 'Loading fresh products...'),
                    ),
                    error: (error, stack) => ErrorView(
                      message: 'Failed to load products',
                      onRetry: () => ref.invalidate(allProductsProvider),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, {required String title, VoidCallback? onViewAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          if (onViewAll != null)
            TextButton(
              onPressed: onViewAll,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: AppColors.primary,
              ),
              child: const Row(
                children: [
                  Text('See all', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  Icon(Icons.chevron_right_rounded, size: 18),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: GestureDetector(
        onTap: () => context.push('/search'),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
              const SizedBox(width: 12),
              Text(
                'Search "milk", "bread" or "eggs"',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0C831F), Color(0xFF14A42C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(Icons.shopping_basket_rounded, size: 140, color: Colors.white.withOpacity(0.15)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'FREE DELIVERY',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Get 50% OFF on\nyour first order',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid(BuildContext context, List<Map<String, dynamic>> categories) {
    final displayCategories = categories.length > 8 ? categories.sublist(0, 8) : categories;
    
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
        itemCount: displayCategories.length,
        itemBuilder: (context, index) {
          final category = displayCategories[index];
          final categoryName = category['name'] as String;
          final imageUrl = category['image_url'] as String?;

          return GestureDetector(
            onTap: () => context.push('/category/$categoryName'),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3FBF4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE8F5E9)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(8),
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.contain,
                                errorWidget: (context, url, error) => Icon(_getCategoryIcon(categoryName), color: AppColors.primary, size: 30),
                              ),
                            )
                          : Icon(_getCategoryIcon(categoryName), color: AppColors.primary, size: 30),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  Formatters.formatCategoryName(categoryName),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
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
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(product: products[index]);
      },
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

  List _getRotatedFeaturedProducts(List products, int count) {
    if (products.isEmpty) return [];
    if (products.length <= count) return products;
    final productsCopy = List.from(products);
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final seed = now.year * 1000 + dayOfYear;
    productsCopy.shuffle(Random(seed));
    return productsCopy.take(count).toList();
  }
}
