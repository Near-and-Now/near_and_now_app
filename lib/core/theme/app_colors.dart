import 'package:flutter/material.dart';

/// App color palette - Blinkit-inspired professional design
class AppColors {
  // Primary colors (Blinkit Green theme)
  static const Color primary = Color(0xFF0C831F); // Blinkit Green
  static const Color secondary = Color(0xFF0A6B1A); // Darker Green
  static const Color accent = Color(0xFF10b981); // Accent Green
  static const Color primaryLight = Color(0xFF34d399); // Light Green
  static const Color primaryDark = Color(0xFF065f46); // Dark Green
  
  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Background colors
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3F4F6);
  
  // Text colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textDisabled = Color(0xFFD1D5DB);
  
  // Border colors
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);
  
  // Badge/Tag colors
  static const Color badgeRed = Color(0xFFFEE2E2);
  static const Color badgeRedText = Color(0xFFDC2626);
  static const Color badgeGreen = Color(0xFFD1FAE5);
  static const Color badgeGreenText = Color(0xFF059669);
  static const Color badgeBlue = Color(0xFFDBEAFE);
  static const Color badgeBlueText = Color(0xFF2563EB);
  static const Color badgeYellow = Color(0xFFFEF3C7);
  static const Color badgeYellowText = Color(0xFFD97706);
  
  // Shadow
  static final BoxShadow shadowSm = BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 4,
    offset: const Offset(0, 1),
  );
  
  static final BoxShadow shadowMd = BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 8,
    offset: const Offset(0, 2),
  );
  
  static final BoxShadow shadowLg = BoxShadow(
    color: Colors.black.withOpacity(0.15),
    blurRadius: 16,
    offset: const Offset(0, 4),
  );
}

