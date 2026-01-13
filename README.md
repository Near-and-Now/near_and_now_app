# Near & Now - Flutter Mobile App

A complete Flutter e-commerce mobile application for the Near & Now grocery delivery platform, built with Flutter, Riverpod, and Supabase.

## 🚀 Features

### Core Features
- ✅ **Product Browsing**: Browse all products with categories
- ✅ **Product Search**: Real-time product search
- ✅ **Product Details**: View detailed product information with images
- ✅ **Shopping Cart**: Add, update, and remove items with persistent storage
- ✅ **Checkout Flow**: Complete checkout with address and payment selection
- ✅ **Order Management**: View order history and status
- ✅ **User Authentication**: OTP-based phone authentication via Supabase
- ✅ **User Profile**: View and manage user profile
- ✅ **Address Management**: Save and manage delivery addresses
- ✅ **Responsive Design**: Optimized for both Android and iOS

### UI/UX Features
- Modern Material Design 3 with custom theme
- Bottom navigation for easy access
- Pull-to-refresh on all lists
- Loading states and error handling
- Empty state screens
- Smooth animations and transitions

## 📱 Screenshots

(Add screenshots here after running the app)

## 🛠️ Technical Stack

### Framework & Language
- **Flutter** 3.0+ - Cross-platform mobile framework
- **Dart** 3.0+ - Programming language

### State Management
- **Riverpod** 2.4+ - Reactive state management

### Backend & Database
- **Supabase** - Backend as a Service (BaaS)
  - PostgreSQL database
  - Authentication
  - Real-time subscriptions
  - Storage

### Key Dependencies
```yaml
dependencies:
  flutter_riverpod: ^2.4.9          # State management
  supabase_flutter: ^2.0.0          # Backend integration
  go_router: ^12.1.3                # Navigation
  cached_network_image: ^3.3.0      # Image caching
  google_fonts: ^6.1.0              # Typography
  shared_preferences: ^2.2.2        # Local storage
  hive_flutter: ^1.1.0              # Local database
  pinput: ^3.0.1                    # OTP input
  intl: ^0.18.1                     # Internationalization
```

## 📁 Project Structure

```
lib/
├── main.dart                       # App entry point
├── core/                           # Core functionality
│   ├── config/
│   │   └── app_config.dart         # App configuration
│   ├── models/                     # Data models
│   │   ├── product_model.dart
│   │   ├── order_model.dart
│   │   ├── user_model.dart
│   │   ├── address_model.dart
│   │   └── cart_item_model.dart
│   ├── services/
│   │   └── supabase_service.dart   # Supabase API service
│   ├── theme/                      # App theme
│   │   ├── app_theme.dart
│   │   └── app_colors.dart
│   ├── routes/
│   │   └── app_router.dart         # Navigation routes
│   ├── widgets/                    # Reusable widgets
│   │   ├── custom_button.dart
│   │   ├── custom_text_field.dart
│   │   ├── product_card.dart
│   │   ├── loading_indicator.dart
│   │   ├── empty_state.dart
│   │   ├── error_view.dart
│   │   └── main_navigation.dart
│   └── utils/
│       └── formatters.dart         # Utility functions
├── features/                       # Feature modules
│   ├── auth/
│   │   ├── providers/
│   │   │   └── auth_provider.dart
│   │   └── screens/
│   │       └── login_screen.dart
│   ├── home/
│   │   └── screens/
│   │       └── home_screen.dart
│   ├── shop/
│   │   └── screens/
│   │       └── shop_screen.dart
│   ├── products/
│   │   ├── providers/
│   │   │   └── products_provider.dart
│   │   └── screens/
│   │       ├── product_detail_screen.dart
│   │       └── category_screen.dart
│   ├── cart/
│   │   ├── providers/
│   │   │   └── cart_provider.dart
│   │   ├── screens/
│   │   │   └── cart_screen.dart
│   │   └── widgets/
│   │       └── cart_item_card.dart
│   ├── checkout/
│   │   └── screens/
│   │       ├── checkout_screen.dart
│   │       └── thank_you_screen.dart
│   ├── orders/
│   │   └── screens/
│   │       └── orders_screen.dart
│   ├── addresses/
│   │   └── screens/
│   │       └── addresses_screen.dart
│   ├── search/
│   │   └── screens/
│   │       └── search_screen.dart
│   ├── profile/
│   │   └── screens/
│   │       └── profile_screen.dart
│   └── about/
│       └── screens/
│           └── about_screen.dart
```

## 🔧 Setup Instructions

### Prerequisites
- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- Android Studio / Xcode (for mobile development)
- Supabase account (for backend)

### 1. Clone the Repository
```bash
cd /Users/tiasmondal166/projects/near_and_now_app
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure Supabase
The app is already configured to use the Near & Now Supabase instance. The configuration is in:
```dart
// lib/core/config/app_config.dart
static const String supabaseUrl = 'https://mpbszymyubxavjoxhzfm.supabase.co';
static const String supabaseAnonKey = '[ANON_KEY]';
```

### 4. Run the App
```bash
# For Android
flutter run

# For iOS
flutter run

# For web (not recommended for mobile apps)
flutter run -d chrome
```

## 🎨 Design System

### Color Palette
- **Primary**: `#059669` (Green-600)
- **Secondary**: `#047857` (Green-700)
- **Accent**: `#10b981` (Green-500)
- **Success**: `#10B981`
- **Warning**: `#F59E0B`
- **Error**: `#EF4444`

### Typography
- Font Family: Inter (via Google Fonts)
- Title: 24px, Bold
- Heading: 18px, Bold
- Body: 14px, Regular
- Caption: 12px, Regular

### Spacing
- XS: 4px
- SM: 8px
- MD: 16px
- LG: 24px
- XL: 32px

## 📝 Key Features Implementation

### State Management with Riverpod
```dart
// Provider example
final allProductsProvider = FutureProvider<List<Product>>((ref) async {
  final service = ref.read(productsServiceProvider);
  return await service.getAllProducts();
});

// Consumer example
final productsAsync = ref.watch(allProductsProvider);
productsAsync.when(
  data: (products) => /* show products */,
  loading: () => /* show loading */,
  error: (error, stack) => /* show error */,
);
```

### Cart Persistence
Cart data is automatically saved to local storage using `SharedPreferences`:
```dart
class CartNotifier extends StateNotifier<List<CartItem>> {
  // Automatically loads cart on initialization
  // Saves cart on every change
}
```

### Navigation with GoRouter
```dart
// Navigate to a screen
context.push('/product/$productId');
context.go('/cart');

// Named routes
context.pushNamed('productDetail', params: {'id': productId});
```

## 🔐 Authentication Flow

1. User enters phone number (+91 format)
2. OTP is sent via Supabase Auth
3. User enters 6-digit OTP
4. OTP is verified and user is logged in
5. Session is persisted automatically

## 📦 Build for Production

### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

### iOS
```bash
# Build IPA
flutter build ios --release

# Or use Xcode for final build
open ios/Runner.xcworkspace
```

## 🧪 Testing

```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage

# Run integration tests
flutter drive --target=test_driver/app.dart
```

## 🚀 Deployment

### Android (Google Play Store)
1. Build app bundle: `flutter build appbundle --release`
2. Upload to Google Play Console
3. Fill in store listing details
4. Submit for review

### iOS (App Store)
1. Build IPA: `flutter build ios --release`
2. Open Xcode and archive
3. Upload to App Store Connect
4. Fill in app information
5. Submit for review

## 🐛 Troubleshooting

### Common Issues

**Issue**: Build fails with dependency conflicts
```bash
flutter clean
flutter pub get
flutter pub upgrade
```

**Issue**: Supabase connection errors
- Check internet connection
- Verify Supabase URL and keys in `app_config.dart`
- Check Supabase dashboard for service status

**Issue**: Cart not persisting
- Check SharedPreferences permissions
- Clear app data and try again

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Documentation](https://riverpod.dev)
- [Supabase Documentation](https://supabase.com/docs)
- [GoRouter Documentation](https://pub.dev/packages/go_router)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 👥 Team

Developed by the Near & Now team.

## 📞 Support

For support, email support@nearandnow.com or visit our website at www.nearandnow.com.

---

Made with ❤️ using Flutter