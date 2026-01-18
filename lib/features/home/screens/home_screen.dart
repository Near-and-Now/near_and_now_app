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
import '../providers/home_scroll_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeScrollNotifierProvider.notifier).setController(_scrollController);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(allProductsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Header with Location, Profile Button, and Search Bar
          SliverAppBar(
            pinned: true,
            floating: false,
            snap: false,
            expandedHeight: 170,
            collapsedHeight: 60,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                return FlexibleSpaceBar(
                  background: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Location and Profile Button Row
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                const Expanded(child: LocationWidget()),
                                const SizedBox(width: 12),
                                _buildProfileButton(context),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Search Bar Row
                          _buildSearchBar(context),
                        ],
                      ),
                    ),
                  ),
                );
              },
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
                  const SizedBox(height: 8),

                  // Top Banners and Ads Section
                  _buildTopBannersSection(),

                  const SizedBox(height: 24),

                  // Frequently Bought Items Section
                  _buildSectionHeader(context, title: 'Frequently Bought'),
                  const SizedBox(height: 12),

                  productsAsync.when(
                    data: (products) {
                      final frequent = _getRotatedFeaturedProducts(products, 6);
                      return _buildHorizontalProductList(frequent);
                    },
                    loading: () => const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    error: (error, _) => const SizedBox(),
                  ),

                  const SizedBox(height: 24),

                  // Discounted Products of This Week Section
                  _buildSectionHeader(context, title: 'Discounted Products of This Week'),
                  const SizedBox(height: 12),

                  productsAsync.when(
                    data: (products) {
                      final discounted = _getRotatedFeaturedProducts(products.reversed.toList(), 4);
                      return _buildProductsGrid(discounted);
                    },
                    loading: () => const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    error: (error, _) => const SizedBox(),
                  ),

                  const SizedBox(height: 24),

                  // Categories Section
                  _buildSectionHeader(
                    context,
                    title: 'Shop by Category',
                    onViewAll: () => context.go('/categories')
                  ),
                  const SizedBox(height: 8),

                  categoriesAsync.when(
                    data: (categories) => _buildCategoriesGrid(context, categories),
                    loading: () => const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    error: (error, _) => const SizedBox(),
                  ),

                  const SizedBox(height: 24),

                  // Shop by Offers Section
                  _buildSectionHeader(context, title: 'Shop by Offers'),
                  const SizedBox(height: 12),

                  _buildOffersSection(),

                  const SizedBox(height: 24),

                  // Bottom Banners and Ads Section
                  _buildBottomBannersSection(),

                  const SizedBox(height: 32),

                  // Footer
                  _buildFooter(),
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
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
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
              Expanded(
                child: Text(
                  'Search "milk", "bread" or "eggs"',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
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
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Icon(_getCategoryIcon(categoryName), color: AppColors.primary, size: 30),
                            )
                          : Icon(_getCategoryIcon(categoryName), color: AppColors.primary, size: 30),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
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

  Widget _buildProfileButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/profile'),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.person_outline,
          color: AppColors.primary,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildTopBannersSection() {
    return Column(
      children: [
        _buildPromoBanner(),
        const SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Special Offer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Buy 2 Get 1 Free',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalProductList(List products) {
    return SizedBox(
      height: 240,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            margin: EdgeInsets.only(right: index < products.length - 1 ? 12 : 0),
            child: ProductCard(product: products[index]),
          );
        },
      ),
    );
  }

  Widget _buildOffersSection() {
    return SizedBox(
      height: 120,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        children: [
          _buildOfferCard(
            'Flash Sale',
            'Up to 70% OFF',
            const Color(0xFFFFD700),
            Icons.flash_on,
          ),
          const SizedBox(width: 12),
          _buildOfferCard(
            'Weekend Deal',
            'Extra 20% OFF',
            const Color(0xFF4CAF50),
            Icons.weekend,
          ),
          const SizedBox(width: 12),
          _buildOfferCard(
            'Combo Offers',
            'Save More',
            const Color(0xFF2196F3),
            Icons.local_offer,
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(String title, String subtitle, Color color, IconData icon) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBannersSection() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Download Our App',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Get exclusive app-only deals',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.shopping_bag,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Near & Now',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Fresh groceries in 8 minutes',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '© 2026 Near & Now. All rights reserved.',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
