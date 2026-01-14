import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/config/app_config.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Icon/Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [AppColors.shadowMd],
              ),
              child: const Icon(
                Icons.shopping_bag,
                size: 50,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              AppConfig.appName,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: 8),
            
            const Text(
              'Version ${AppConfig.appVersion}',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            
            const SizedBox(height: 32),
            
            const Divider(),
            
            const SizedBox(height: 24),
            
            const Text(
              'Fresh groceries delivered to your doorstep',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            _buildInfoSection(
              icon: Icons.store,
              title: 'Our Mission',
              description:
                  'To provide fresh, quality groceries at your doorstep with convenience and reliability.',
            ),
            
            const SizedBox(height: 24),
            
            _buildInfoSection(
              icon: Icons.local_shipping,
              title: 'Fast Delivery',
              description:
                  'We ensure timely delivery of your groceries to keep them fresh and ready to use.',
            ),
            
            const SizedBox(height: 24),
            
            _buildInfoSection(
              icon: Icons.verified_user,
              title: 'Quality Assured',
              description:
                  'All products are carefully selected and quality-checked before delivery.',
            ),
            
            const SizedBox(height: 48),
            
            const Divider(),
            
            const SizedBox(height: 24),
            
            _buildContactInfo(
              icon: Icons.email,
              text: 'support@nearandnow.com',
            ),
            
            const SizedBox(height: 12),
            
            _buildContactInfo(
              icon: Icons.phone,
              text: '+91 98765 43210',
            ),
            
            const SizedBox(height: 12),
            
            _buildContactInfo(
              icon: Icons.language,
              text: 'www.nearandnow.com',
            ),
            
            const SizedBox(height: 32),
            
            const Text(
              '© 2024 ${AppConfig.appName}. All rights reserved.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 24,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo({
    required IconData icon,
    required String text,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

