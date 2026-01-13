import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/models/order_model.dart';
import '../../auth/providers/auth_provider.dart';

final userOrdersProvider = FutureProvider<List<Order>>((ref) async {
  final user = await ref.read(authServiceProvider).getCurrentUser();
  if (user == null) return [];
  
  return await SupabaseService().getUserOrders(
    userId: user.id,
    userPhone: user.phone,
    userEmail: user.email,
  );
});

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(userOrdersProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    if (!isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Orders')),
        body: EmptyState(
          icon: Icons.login,
          title: 'Login Required',
          message: 'Please login to view your orders',
          actionText: 'Login',
          onAction: () => context.push('/login'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No Orders Yet',
              message: 'Your order history will appear here',
              actionText: 'Start Shopping',
              onAction: () => context.go('/shop'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userOrdersProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return OrderCard(order: orders[index]);
              },
            ),
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading orders...'),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 60,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text('Failed to load orders: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(userOrdersProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppColors.shadowSm],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${order.orderNumber ?? 'N/A'}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              _buildStatusBadge(order.orderStatus),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Order Date
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                Formatters.formatDate(order.createdAt),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Items Count
          if (order.items != null)
            Row(
              children: [
                const Icon(Icons.shopping_bag_outlined, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  '${order.items!.length} item(s)',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          
          const Divider(height: 24),
          
          // Order Total & Payment Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Formatters.formatCurrency(order.orderTotal),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              _buildPaymentStatusBadge(order.paymentStatus),
            ],
          ),
          
          // Order Items (if available)
          if (order.items != null && order.items!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Items',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ...order.items!.take(3).map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• ${item.name} x${item.quantity}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            )),
            if (order.items!.length > 3)
              Text(
                '... and ${order.items!.length - 3} more',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textTertiary,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color bgColor;
    Color textColor;
    
    switch (status) {
      case OrderStatus.placed:
        bgColor = AppColors.badgeBlue;
        textColor = AppColors.badgeBlueText;
        break;
      case OrderStatus.confirmed:
        bgColor = AppColors.badgeYellow;
        textColor = AppColors.badgeYellowText;
        break;
      case OrderStatus.shipped:
        bgColor = AppColors.badgeBlue;
        textColor = AppColors.badgeBlueText;
        break;
      case OrderStatus.delivered:
        bgColor = AppColors.badgeGreen;
        textColor = AppColors.badgeGreenText;
        break;
      case OrderStatus.cancelled:
        bgColor = AppColors.badgeRed;
        textColor = AppColors.badgeRedText;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildPaymentStatusBadge(PaymentStatus status) {
    Color bgColor;
    Color textColor;
    
    switch (status) {
      case PaymentStatus.pending:
        bgColor = AppColors.badgeYellow;
        textColor = AppColors.badgeYellowText;
        break;
      case PaymentStatus.paid:
        bgColor = AppColors.badgeGreen;
        textColor = AppColors.badgeGreenText;
        break;
      case PaymentStatus.failed:
      case PaymentStatus.refunded:
        bgColor = AppColors.badgeRed;
        textColor = AppColors.badgeRedText;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

