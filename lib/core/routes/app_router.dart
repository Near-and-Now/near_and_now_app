import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/screens/home_screen.dart';
import '../../features/shop/screens/shop_screen.dart';
import '../../features/cart/screens/cart_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/products/screens/product_detail_screen.dart';
import '../../features/products/screens/category_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/checkout/screens/checkout_screen.dart';
import '../../features/checkout/screens/thank_you_screen.dart';
import '../../features/orders/screens/orders_screen.dart';
import '../../features/addresses/screens/addresses_screen.dart';
import '../../features/about/screens/about_screen.dart';
import '../widgets/main_navigation.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // Main navigation with bottom bar
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigation(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/shop',
            name: 'shop',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ShopScreen(),
            ),
          ),
          GoRoute(
            path: '/cart',
            name: 'cart',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CartScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),
      
      // Standalone screens
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/product/:id',
        name: 'productDetail',
        builder: (context, state) {
          final productId = state.pathParameters['id']!;
          return ProductDetailScreen(productId: productId);
        },
      ),
      GoRoute(
        path: '/category/:name',
        name: 'category',
        builder: (context, state) {
          final categoryName = state.pathParameters['name']!;
          return CategoryScreen(categoryName: categoryName);
        },
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/checkout',
        name: 'checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/thank-you/:orderId',
        name: 'thankYou',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return ThankYouScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/orders',
        name: 'orders',
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/addresses',
        name: 'addresses',
        builder: (context, state) => const AddressesScreen(),
      ),
      GoRoute(
        path: '/about',
        name: 'about',
        builder: (context, state) => const AboutScreen(),
      ),
    ],
  );
});

