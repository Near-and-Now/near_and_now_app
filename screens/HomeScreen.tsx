import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  ScrollView,
  StyleSheet,
  TouchableOpacity,
  FlatList,
  Image,
  RefreshControl,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { getAllProducts, Product } from '../services/supabase';
import { getCategories, Category } from '../services/adminService';
import { Theme } from '../constants/Theme';
import ProductCard from '../components/ProductCard';
import { formatCategoryName } from '../utils/formatters';
import { useNotification } from '../context/NotificationContext';
import { Ionicons } from '@expo/vector-icons';

const HomeScreen: React.FC = () => {
  const navigation = useNavigation();
  const { showNotification } = useNotification();
  const [allProducts, setAllProducts] = useState<Product[]>([]);
  const [displayedProducts, setDisplayedProducts] = useState<Product[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [itemsToShow, setItemsToShow] = useState(12);

  useEffect(() => {
    fetchData();
  }, []);

  useEffect(() => {
    setDisplayedProducts(allProducts.slice(0, itemsToShow));
  }, [allProducts, itemsToShow]);

  const fetchData = async () => {
    try {
      setLoading(true);
      const [products, categoriesData] = await Promise.all([
        getAllProducts(),
        getCategories(),
      ]);
      setAllProducts(products);
      setCategories(categoriesData);
    } catch (error) {
      console.error('Error fetching data:', error);
      showNotification('Failed to load data. Please try again.', 'error');
    } finally {
      setLoading(false);
    }
  };

  const onRefresh = async () => {
    setRefreshing(true);
    await fetchData();
    setRefreshing(false);
  };

  const loadMore = () => {
    if (itemsToShow < allProducts.length) {
      setItemsToShow(itemsToShow + 12);
    }
  };

  const handleCategoryPress = (category: Category) => {
    navigation.navigate('Category' as never, {
      categoryId: category.name,
      categoryName: formatCategoryName(category.name),
    } as never);
  };

  const handleSearchPress = () => {
    navigation.navigate('Search' as never);
  };

  return (
    <ScrollView
      style={styles.container}
      refreshControl={
        <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
      }
    >
      {/* Header Section */}
      <View style={styles.header}>
        <View style={styles.logoContainer}>
          <Text style={styles.logoText}>Near & Now</Text>
          <Text style={styles.tagline}>Digital Dukan, Local Dil Se</Text>
        </View>
        <TouchableOpacity
          style={styles.searchButton}
          onPress={handleSearchPress}
        >
          <Ionicons name="search" size={24} color={Theme.colors.text} />
        </TouchableOpacity>
      </View>

      {/* Categories Section */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Shop by Category</Text>
        <Text style={styles.sectionSubtitle}>
          Discover a wide variety of fresh products
        </Text>

        {loading ? (
          <View style={styles.loadingContainer}>
            <Text>Loading categories...</Text>
          </View>
        ) : (
          <FlatList
            data={categories}
            horizontal
            showsHorizontalScrollIndicator={false}
            keyExtractor={(item) => item.id}
            renderItem={({ item, index }) => (
              <TouchableOpacity
                style={styles.categoryCard}
                onPress={() => handleCategoryPress(item)}
              >
                <View
                  style={[
                    styles.categoryImageContainer,
                    { backgroundColor: getCategoryColor(index) },
                  ]}
                >
                  <Image
                    source={{
                      uri:
                        item.image_url ||
                        `https://via.placeholder.com/200x200?text=${encodeURIComponent(item.name)}`,
                    }}
                    style={styles.categoryImage}
                    resizeMode="cover"
                  />
                </View>
                <Text style={styles.categoryName} numberOfLines={2}>
                  {formatCategoryName(item.name)}
                </Text>
              </TouchableOpacity>
            )}
            contentContainerStyle={styles.categoriesList}
          />
        )}
      </View>

      {/* Products Section */}
      <View style={styles.section}>
        <View style={styles.sectionHeader}>
          <View>
            <Text style={styles.sectionTitle}>Our Products</Text>
            <Text style={styles.sectionSubtitle}>
              {allProducts.length > 0
                ? `Showing ${displayedProducts.length} of ${allProducts.length} products`
                : 'Browse through our complete collection'}
            </Text>
          </View>
        </View>

        {loading ? (
          <View style={styles.loadingContainer}>
            <Text>Loading products...</Text>
          </View>
        ) : displayedProducts.length > 0 ? (
          <View style={styles.productsGrid}>
            {displayedProducts.map((product) => (
              <View key={product.id} style={styles.productWrapper}>
                <ProductCard product={product} />
              </View>
            ))}
          </View>
        ) : (
          <View style={styles.emptyContainer}>
            <Text style={styles.emptyText}>No products available</Text>
          </View>
        )}

        {displayedProducts.length < allProducts.length && (
          <TouchableOpacity style={styles.loadMoreButton} onPress={loadMore}>
            <Text style={styles.loadMoreText}>Load More Products</Text>
          </TouchableOpacity>
        )}
      </View>
    </ScrollView>
  );
};

const getCategoryColor = (index: number): string => {
  const colors = [
    Theme.colors.gray50,
    Theme.colors.gray100,
    Theme.colors.gray50,
    Theme.colors.gray100,
  ];
  return colors[index % colors.length];
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Theme.colors.background,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: Theme.spacing.md,
    backgroundColor: Theme.colors.white,
    ...Theme.shadows.sm,
  },
  logoContainer: {
    flex: 1,
  },
  logoText: {
    fontSize: Theme.fontSize.xxl,
    fontWeight: Theme.fontWeight.bold,
    color: Theme.colors.primary,
  },
  tagline: {
    fontSize: Theme.fontSize.sm,
    color: Theme.colors.textSecondary,
    marginTop: 4,
  },
  searchButton: {
    padding: Theme.spacing.sm,
  },
  section: {
    padding: Theme.spacing.md,
    marginTop: Theme.spacing.md,
  },
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: Theme.spacing.md,
  },
  sectionTitle: {
    fontSize: Theme.fontSize.xl,
    fontWeight: Theme.fontWeight.bold,
    color: Theme.colors.text,
    marginBottom: Theme.spacing.xs,
  },
  sectionSubtitle: {
    fontSize: Theme.fontSize.sm,
    color: Theme.colors.textSecondary,
  },
  categoriesList: {
    paddingRight: Theme.spacing.md,
  },
  categoryCard: {
    width: 120,
    marginRight: Theme.spacing.md,
    backgroundColor: Theme.colors.white,
    borderRadius: Theme.borderRadius.lg,
    overflow: 'hidden',
    ...Theme.shadows.md,
  },
  categoryImageContainer: {
    width: '100%',
    height: 120,
    justifyContent: 'center',
    alignItems: 'center',
  },
  categoryImage: {
    width: '100%',
    height: '100%',
  },
  categoryName: {
    fontSize: Theme.fontSize.sm,
    fontWeight: Theme.fontWeight.medium,
    color: Theme.colors.text,
    padding: Theme.spacing.sm,
    textAlign: 'center',
  },
  productsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
  },
  productWrapper: {
    width: '48%',
    marginBottom: Theme.spacing.md,
  },
  loadingContainer: {
    padding: Theme.spacing.xl,
    alignItems: 'center',
  },
  emptyContainer: {
    padding: Theme.spacing.xl,
    alignItems: 'center',
  },
  emptyText: {
    fontSize: Theme.fontSize.md,
    color: Theme.colors.textSecondary,
  },
  loadMoreButton: {
    marginTop: Theme.spacing.md,
    padding: Theme.spacing.md,
    backgroundColor: Theme.colors.primary,
    borderRadius: Theme.borderRadius.md,
    alignItems: 'center',
  },
  loadMoreText: {
    color: Theme.colors.white,
    fontSize: Theme.fontSize.md,
    fontWeight: Theme.fontWeight.semibold,
  },
});

export default HomeScreen;

