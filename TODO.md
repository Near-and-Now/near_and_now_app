# 📋 TODO List - Near & Now Flutter App

**Last Updated:** January 18, 2026
**Project Status:** Development Ready - Testing Phase

---

## 🎯 Current Sprint - Essential Tasks

### ✅ Recently Completed (Latest)

#### Compilation & Build Fixes

- [X] Fixed CardTheme compilation error in `app_theme.dart`
- [X] Fixed CachedNetworkImage padding parameter error in `home_screen.dart`
- [X] All compilation errors resolved
- [X] App builds successfully

#### API Key Security Implementation

- [X] Removed hardcoded API key from `places_service.dart`
- [X] Moved API key to `AppConfig` using `String.fromEnvironment()`
- [X] Created `run_with_api_key.bat` script for secure local development
- [X] Added API key protection to `.gitignore`
- [X] Created `SECURITY_GUIDE.md` documentation

#### Google Places API Fixes

- [X] Fixed `REQUEST_DENIED` error (API key restrictions)
- [X] Fixed `INVALID_REQUEST` error (changed types to 'geocode' only)
- [X] Google Places autocomplete working
- [X] Address search functionality operational

#### Location Priority System

- [X] Implemented manual vs GPS location priority
- [X] Manual address selection takes precedence over GPS
- [X] Location persistence via SharedPreferences
- [X] Location invalidation/refresh system working
- [X] Location widget updated to show correct address

---

## 🔥 High Priority - Do This Week

### 1. ~~API Key Configuration~~ ✅ COMPLETE

- [X] **Google Maps API Key - Fully Configured & Secured**

  - [X] Google Cloud project created
  - [X] Required APIs enabled (Places, Geocoding, Maps)
  - [X] API key generated and configured
  - [X] API key secured (moved to environment variables)
  - [X] API restrictions configured (Android app)
  - [X] Test location search functionality ✅ WORKING
  - [X] Address autocomplete working ✅ WORKING
  - [X] Verify billing alerts are set

  - ✅ **Status:** API key is configured and secured!
  - 📝 **Note:** Use `run_with_api_key.bat` to run the app
  - 🔒 **Security:** API key no longer hardcoded, uses `--dart-define`

### 2. Initial Testing & Debugging

- [X] **Run app on Samsung S928B (Android 16)** ✅ TESTED

  ```bash
  flutter run -d adb-RZCY60YV2DY-PVwcl0._adb-tls-connect._tcp
  ```

  - [X] App launches successfully
  - [X] All screens load correctly
  - [X] Navigation between screens works
  - [X] No critical runtime errors
  - [X] Location services working with real GPS
  - [X] Google Places search working

  - ⏱️ **Time Spent:** ~3 hours
  - 📝 **Device:** Samsung SM-S928B, Android 16 (real device testing)
- [X] **Test core user flows**

  - [X] Browse products on home screen ✅
  - [ ] Search for products
  - [ ] View product details
  - [ ] Add items to cart
  - [ ] View cart
  - [ ] Proceed to checkout
  - [ ] Place test order

  - ⏱️ **Estimated Time:** 1 hour (50% complete)
- [ ] **Test authentication**

  - [ ] Phone number entry
  - [ ] OTP sending (verify Supabase config)
  - [ ] OTP verification
  - [ ] Session persistence
  - [ ] Logout functionality

  - ⏱️ **Estimated Time:** 30 minutes

### 3. Backend Verification

- [ ] **Verify Supabase database tables exist**

  - [ ] `products` table with required columns
  - [ ] `categories` table with image_url
  - [ ] `orders` table structure
  - [ ] `users` table structure
  - [ ] `addresses` table structure
  - [ ] Check Row Level Security (RLS) policies

  - ⏱️ **Estimated Time:** 45 minutes
- [ ] **Test data operations**

  - [ ] Fetch products successfully
  - [ ] Fetch categories with images
  - [ ] Create order
  - [ ] Update user profile
  - [ ] Save addresses

  - ⏱️ **Estimated Time:** 1 hour

### 4. Location Services Testing

- [X] **Test GPS location detection** ✅ WORKING

  - [X] Real device GPS location (Samsung S928B)
  - [X] Request location permissions
  - [X] Verify address geocoding works
  - [X] Test location caching via SharedPreferences

  - ⏱️ **Time Spent:** 1 hour
  - ✅ **Result:** GPS detection working perfectly on real device
- [X] **Test location picker** ✅ WORKING

  - [X] Open location picker sheet
  - [X] Use current location button - working
  - [X] Search for addresses (Google Places API) - working
  - [X] Select from search results - working
  - [X] Verify location persistence - working
  - [X] Manual location takes priority over GPS ✅ IMPLEMENTED

  - ⏱️ **Time Spent:** 2 hours
  - ✅ **Result:** Location priority system working correctly
  - 📝 **Note:** Manual selection overrides GPS as intended

---

## 📱 Medium Priority - Next 2 Weeks

### 5. UI/UX Polish

- [ ] **Review and fix UI issues**

  - [ ] Check responsive design on different screen sizes
  - [ ] Verify image loading and caching
  - [ ] Test pull-to-refresh on all screens
  - [ ] Check loading states
  - [ ] Verify error messages are user-friendly
  - [ ] Test empty states

  - ⏱️ **Estimated Time:** 3 hours
- [ ] **Optimize animations**

  - [ ] Review page transitions
  - [ ] Check button animations
  - [ ] Verify product card animations
  - [ ] Test cart badge updates

  - ⏱️ **Estimated Time:** 2 hours

### 6. Real Device Testing

- [ ] **Test on physical Android device**

  ```bash
  flutter run -d <device-id>
  ```

  - [ ] Real GPS location
  - [ ] Camera (if product image upload exists)
  - [ ] Actual network conditions
  - [ ] Battery usage
  - [ ] Performance metrics

  - ⏱️ **Estimated Time:** 2 hours
- [ ] **Test on iOS device (if Mac available)**

  ```bash
  flutter run -d <ios-device-id>
  ```

  - [ ] iOS-specific UI elements
  - [ ] iOS location permissions
  - [ ] iOS-specific bugs

  - ⏱️ **Estimated Time:** 2 hours

### 7. Error Handling & Edge Cases

- [ ] **Test offline mode**

  - [ ] Disable internet
  - [ ] Verify cached data loads
  - [ ] Check error messages
  - [ ] Test offline cart persistence

  - ⏱️ **Estimated Time:** 1 hour
- [ ] **Test error scenarios**

  - [ ] Invalid OTP entry
  - [ ] Network timeout
  - [ ] API errors
  - [ ] Empty search results
  - [ ] Out of stock products
  - [ ] Invalid addresses

  - ⏱️ **Estimated Time:** 2 hours

### 8. Performance Optimization

- [ ] **Measure and optimize**

  - [ ] Run Flutter DevTools profiler
  - [ ] Check for memory leaks
  - [ ] Optimize image loading
  - [ ] Review provider rebuilds
  - [ ] Check app startup time

  - ⏱️ **Estimated Time:** 3 hours

---

## 🚀 Low Priority - Before Launch

### 9. Payment Integration (If Needed)

- [ ] **Decide on payment gateway**

  - [ ] Razorpay (recommended for India)
  - [ ] Stripe
  - [ ] PayPal
  - [ ] Cash on Delivery only?
- [ ] **Implement payment flow** (if online payment needed)

  - [ ] Add payment gateway package
  - [ ] Create payment screen
  - [ ] Integrate payment API
  - [ ] Handle payment callbacks
  - [ ] Test payment flow
  - [ ] Add payment history

  - ⏱️ **Estimated Time:** 8-10 hours

### 10. App Store Preparation

- [ ] **Android (Google Play)**

  - [ ] Create app icon (1024x1024)
  - [ ] Create feature graphic (1024x500)
  - [ ] Add splash screen
  - [ ] Configure app signing
  - [ ] Generate release APK/AAB
  - [ ] Prepare store listing:
    - [ ] App description
    - [ ] Screenshots (4-8 required)
    - [ ] Privacy policy URL
    - [ ] Contact information

  - ⏱️ **Estimated Time:** 4-6 hours
- [ ] **iOS (App Store)** (If targeting iOS)

  - [ ] Create app icon set
  - [ ] Configure launch screen
  - [ ] Set up provisioning profile
  - [ ] Build archive
  - [ ] Prepare store listing:
    - [ ] App description
    - [ ] Screenshots for all device sizes
    - [ ] Privacy policy
    - [ ] Support URL

  - ⏱️ **Estimated Time:** 6-8 hours

### 11. Additional Features (Enhancement)

- [ ] **Push notifications**

  - [ ] Set up Firebase Cloud Messaging
  - [ ] Implement notification handling
  - [ ] Create notification types:
    - [ ] Order status updates
    - [ ] Promotional offers
    - [ ] New product alerts

  - ⏱️ **Estimated Time:** 4-6 hours
- [ ] **Analytics integration**

  - [ ] Add Firebase Analytics or Mixpanel
  - [ ] Track key events:
    - [ ] Product views
    - [ ] Add to cart
    - [ ] Checkout started
    - [ ] Order completed
    - [ ] Search queries

  - ⏱️ **Estimated Time:** 2-3 hours
- [ ] **Crash reporting**

  - [ ] Set up Firebase Crashlytics or Sentry
  - [ ] Configure error tracking
  - [ ] Test crash reporting

  - ⏱️ **Estimated Time:** 1-2 hours

### 12. Advanced Features (Future)

- [ ] **Order tracking**

  - [ ] Real-time order status
  - [ ] Delivery person tracking on map
  - [ ] ETA updates
  - [ ] Delivery notifications
- [ ] **Favorites/Wishlist**

  - [ ] Add to favorites button
  - [ ] Favorites screen
  - [ ] Sync with backend
- [ ] **Product reviews & ratings**

  - [ ] Review submission form
  - [ ] Display reviews on product page
  - [ ] Rating filter/sort
- [ ] **Offers & Coupons**

  - [ ] Coupon code entry
  - [ ] Apply discount logic
  - [ ] Display savings
  - [ ] Coupon list screen
- [ ] **Multi-language support**

  - [ ] Set up i18n
  - [ ] Translate strings
  - [ ] Language selector
- [ ] **Dark mode**

  - [ ] Create dark theme
  - [ ] Theme switcher
  - [ ] Persist theme preference

---

## 🐛 Known Issues to Fix

### Active Bugs

- [ ] *Currently testing - will update with any issues found*

### Recently Fixed Issues ✅

- [X] CardTheme type mismatch - Fixed by using CardThemeData
- [X] CachedNetworkImage padding error - Fixed by wrapping in Padding widget
- [X] Google Places API REQUEST_DENIED - Fixed by removing API restrictions
- [X] Google Places API INVALID_REQUEST - Fixed by changing types to 'geocode'
- [X] Manual location being overridden by GPS - Fixed with priority system
- [X] Exposed API key security issue - Fixed by moving to environment variables

### Technical Debt

- [ ] Add unit tests for core business logic
- [ ] Add widget tests for critical screens
- [ ] Add integration tests for user flows
- [ ] Document code with better comments
- [ ] Refactor large widgets into smaller components
- [ ] Extract magic numbers to constants

---

## 📊 Testing Checklist

### Functional Testing

- [ ] All screens accessible via navigation
- [ ] All buttons perform expected actions
- [ ] Forms validate correctly
- [ ] Data persists after app restart
- [ ] Authentication works end-to-end
- [ ] Cart operations work correctly
- [ ] Checkout flow completes successfully
- [ ] Orders display correctly
- [ ] Profile updates save
- [ ] Address management works
- [ ] Search returns relevant results
- [ ] Categories filter products correctly

### Non-Functional Testing

- [ ] App loads within 3 seconds
- [ ] Smooth scrolling (60 fps)
- [ ] Images load efficiently
- [ ] No memory leaks
- [ ] Battery consumption is reasonable
- [ ] Works on slow network (3G)
- [ ] Handles no network gracefully
- [ ] Secure data storage
- [ ] No sensitive data in logs

---

## 📝 Documentation Updates Needed

- [ ] Add screenshots to README.md
- [ ] Create user guide/FAQ
- [ ] Document API endpoints used
- [ ] Create developer onboarding guide
- [ ] Document deployment process
- [ ] Create release notes template

---

## ⚙️ Configuration Checklist

### Environment Setup

- [X] Flutter SDK installed
- [X] Dependencies installed (`flutter pub get`)
- [X] Google Maps API key configured ✅
- [X] Supabase credentials in `app_config.dart`
- [ ] Android SDK setup (if building for Android)
- [ ] Xcode setup (if building for iOS)

### Build Configuration

- [ ] App name finalized
- [ ] Package name/Bundle ID set
- [ ] Version number set
- [ ] Build number set
- [ ] Minimum SDK version verified
- [ ] Target SDK version verified
- [ ] Permissions reviewed and justified

---

## 🎯 Success Metrics

### Before Launch

- [ ] Zero crash rate in testing
- [ ] All critical user flows work
- [ ] App approved by test users
- [ ] Performance meets benchmarks
- [ ] Security review passed
- [ ] Legal compliance verified

### Post Launch

- [ ] Track daily active users
- [ ] Monitor crash-free rate (target: 99.5%)
- [ ] Track order completion rate
- [ ] Monitor app store ratings
- [ ] Measure average session time
- [ ] Track cart abandonment rate

---

## 🚦 Next Immediate Actions

**Start here:**

1. ~~**Configure Google Maps API Key**~~ ✅ Done & Secured!

2. ~~**Run the app**~~ ✅ Running on real device!

   ```bash
   # Use this command with API key:
   .\run_with_api_key.bat
   # Or:
   flutter run --dart-define=GOOGLE_MAPS_API_KEY=your_key -d device-id
   ```
3. **Test basic app flow** (1 hour)

   - [X] Launch app ✅
   - [X] Browse products ✅
   - [ ] Add to cart
   - [ ] View cart
4. **Verify backend connection** (30 min)

   - [ ] Check Supabase dashboard
   - [ ] Verify tables exist
   - [ ] Test authentication
5. **Fix any issues found** (varies)

---

## 📞 Resources & Documentation

- **Setup Guides:**

  - `START_HERE.md` - Getting started
  - `API_KEY_SETUP.md` - Google Maps setup
  - `EMULATOR_LOCATION_SETUP.md` - Location testing
- **Technical Docs:**

  - `README.md` - Project overview
  - `FEATURES_IMPLEMENTATION.md` - Feature details
  - `PROJECT_STATUS.md` - Current status
- **Recent Changes:**

  - `RECENT_UPDATES.md` - Latest updates
  - `GOOGLE_PLACES_INTEGRATION.md` - Places API details

---

**Total Estimated Time to Launch:**

- Essential tasks: ~10-15 hours
- Pre-launch polish: ~20-30 hours
- App store submission: ~10-15 hours
- **TOTAL: 40-60 hours**

---

**Status Legend:**

- ✅ Done
- 🔥 High Priority
- 📱 Medium Priority
- 🚀 Low Priority
- ⏱️ Estimated Time
- 📝 Note/Reference

---

*Keep this file updated as you complete tasks!*
