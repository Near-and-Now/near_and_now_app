import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/models/product_model.dart';
import '../../products/providers/products_provider.dart';

enum SortOption { featured, priceAsc, priceDesc, nameAsc, nameDesc }

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  SortOption _sortOption = SortOption.featured;
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(allProductsProvider);
    final categoriesAsync = ref.watch(categoryNamesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortOption = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: SortOption.featured,
                child: Text('Featured'),
              ),
              const PopupMenuItem(
                value: SortOption.priceAsc,
                child: Text('Price: Low to High'),
              ),
              const PopupMenuItem(
                value: SortOption.priceDesc,
                child: Text('Price: High to Low'),
              ),
              const PopupMenuItem(
                value: SortOption.nameAsc,
                child: Text('Name: A to Z'),
              ),
              const PopupMenuItem(
                value: SortOption.nameDesc,
                child: Text('Name: Z to A'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter
          categoriesAsync.when(
            data: (categories) => _buildCategoryFilter(categories),
            loading: () => const SizedBox(height: 50),
            error: (_, __) => const SizedBox(),
          ),
          
          // Products grid
          Expanded(
            child: productsAsync.when(
              data: (products) {
                var filteredProducts = products;
                
                // Filter by category
                if (_selectedCategory != null) {
                  filteredProducts = products
                      .where((p) => p.category == _selectedCategory)
                      .toList();
                }
                
                // Sort products
                filteredProducts = _sortProducts(filteredProducts);
                
                if (filteredProducts.isEmpty) {
                  return const Center(
                    child: Text('No products found'),
                  );
                }
                
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(allProductsProvider);
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      return ProductCard(product: filteredProducts[index]);
                    },
                  ),
                );
              },
              loading: () => const LoadingIndicator(
                message: 'Loading products...',
              ),
              error: (error, stack) => ErrorView(
                message: 'Failed to load products',
                onRetry: () => ref.invalidate(allProductsProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(List<String> categories) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildCategoryChip('All', null),
          ...categories.map((category) => _buildCategoryChip(category, category)),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? value) {
    final isSelected = _selectedCategory == value;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? value : null;
          });
        },
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
      ),
    );
  }

  List<Product> _sortProducts(List<Product> products) {
    final sorted = List<Product>.from(products);
    
    switch (_sortOption) {
      case SortOption.featured:
        // Keep original order (featured)
        break;
      case SortOption.priceAsc:
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceDesc:
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.nameAsc:
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.nameDesc:
        sorted.sort((a, b) => b.name.compareTo(a.name));
        break;
    }
    
    return sorted;
  }
}

