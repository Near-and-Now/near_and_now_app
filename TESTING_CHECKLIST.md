# 🧪 Testing Checklist - Near & Now App

**Date:** January 18, 2026
**Device:** Samsung S928B (Android 16)
**Build:** Debug Mode

---

## 📱 Device Information

- **Model:** Samsung SM S928B
- **OS:** Android 16 (API 36)
- **Connection:** Wireless (ADB)
- **Advantages:** Real GPS, Real network, Real camera

---

## ✅ Testing Phases

### Phase 1: App Launch & Navigation (10 min)

#### Basic Functionality

- [X] App launches successfully
- [X] Splash screen displays (if any)
- [X] Home screen loads
- [X] No crash on startup
- [X] Bottom navigation visible (Home, Shop, Cart, Profile)

#### Navigation Test

- [ ] Tap Home tab - loads home screen
- [ ] Tap Shop tab - loads shop screen
- [ ] Tap Cart tab - loads cart screen
- [ ] Tap Profile tab - loads profile screen
- [ ] Back button works correctly
- [ ] Navigation transitions are smooth

**✅ Pass Criteria:** All screens accessible, no crashes

---

### Phase 2: Location Features (15 min)

#### Current Location (Real GPS!)

- [ ] Location widget visible on home screen
- [ ] Tap location widget - location picker opens
- [ ] Tap "Use Current Location" button
- [ ] Permission dialog appears (first time)
- [ ] Grant location permission
- [ ] GPS detects real location
- [ ] Address shows your actual location
- [ ] Location picker closes
- [ ] Location displayed on home screen

**Expected:** Your real address in India

#### Address Search (Google Places API)

- [ ] Open location picker again
- [ ] Tap search box
- [ ] Type your city name (e.g., "Mumbai")
- [ ] Autocomplete suggestions appear (max 5)
- [ ] Suggestions are relevant to India
- [ ] Tap any suggestion
- [ ] Full address details load
- [ ] Location picker closes
- [ ] Selected address displayed

#### Saved Addresses

- [ ] Open location picker
- [ ] Previously used addresses shown
- [ ] Tap a saved address
- [ ] Address loads correctly
- [ ] Maximum 5 addresses saved

**✅ Pass Criteria:** GPS works, search works, addresses save

---

### Phase 3: Product Browsing (15 min)

#### Home Screen Products

- [ ] Featured products visible
- [ ] Product images load
- [ ] Product names display
- [ ] Prices show correctly
- [ ] "Add to Cart" buttons visible

#### Categories

- [ ] Category grid visible (8 categories)
- [ ] Category images load from database
- [ ] Category names display
- [ ] Tap category - navigates to category screen
- [ ] Category products load
- [ ] Back button returns to home

#### Product Details

- [ ] Tap any product card
- [ ] Product detail screen opens
- [ ] Product image loads (full size)
- [ ] Title, description, price visible
- [ ] Unit/weight information shown
- [ ] "Add to Cart" button visible
- [ ] Quantity selector works (+/-)

#### Pull to Refresh

- [ ] Pull down on home screen
- [ ] Refresh indicator appears
- [ ] Products reload
- [ ] Categories reload

**✅ Pass Criteria:** All products load with images, categories work

---

### Phase 4: Shopping Cart (15 min)

#### Adding Items

- [ ] Tap "Add to Cart" on home screen product
- [ ] Button changes to "Added" with checkmark
- [ ] Cart badge updates with count
- [ ] Add another product
- [ ] Cart badge increments

#### Cart Screen

- [ ] Navigate to Cart tab
- [ ] All added items visible
- [ ] Product images show
- [ ] Prices correct
- [ ] Quantity selectors work
- [ ] Increase quantity (+)
- [ ] Decrease quantity (-)
- [ ] Subtotal updates correctly

#### Cart Actions

- [ ] Swipe item to delete (or delete button)
- [ ] Item removes from cart
- [ ] Cart badge decrements
- [ ] Empty cart shows empty state
- [ ] Add items again

#### Cart Persistence

- [ ] Add items to cart
- [ ] Close app (swipe away)
- [ ] Reopen app
- [ ] Cart items still there ✅

**✅ Pass Criteria:** Cart works, persists across restarts

---

### Phase 5: Search (10 min)

#### Product Search

- [ ] Tap search icon/bar on home screen
- [ ] Search screen opens
- [ ] Search box active
- [ ] Type product name (e.g., "milk")
- [ ] Results appear in real-time
- [ ] Results are relevant
- [ ] Tap result - product details open
- [ ] Empty search shows message

**✅ Pass Criteria:** Search returns relevant results

---

### Phase 6: Authentication (15 min)

#### OTP Login

- [ ] Navigate to Profile tab
- [ ] If not logged in, shows login screen
- [ ] Enter phone number (+91 format)
- [ ] Tap "Send OTP"
- [ ] OTP sent (check Supabase logs)
- [ ] OTP entry screen appears
- [ ] Enter 6-digit OTP
- [ ] Tap "Verify"
- [ ] Login successful
- [ ] Profile screen shows user info

#### Session Persistence

- [ ] After login, close app
- [ ] Reopen app
- [ ] User still logged in ✅
- [ ] Profile accessible

#### Logout

- [ ] Tap logout button
- [ ] Confirmation dialog (if any)
- [ ] User logged out
- [ ] Login screen appears

**✅ Pass Criteria:** OTP authentication works end-to-end

---

### Phase 7: Checkout Flow (20 min)

#### Prepare Cart

- [ ] Add 3-5 products to cart
- [ ] Navigate to cart
- [ ] Verify items and totals

#### Checkout Process

- [ ] Tap "Proceed to Checkout" button
- [ ] Checkout screen loads
- [ ] Order summary visible
- [ ] Subtotal shown
- [ ] Delivery fee calculated
- [ ] Total calculated correctly

#### Delivery Address

- [ ] Address section visible
- [ ] Current address pre-selected (if set)
- [ ] Tap "Change Address" (if available)
- [ ] Can select different address
- [ ] Or add new address

#### Payment Method

- [ ] Payment options visible
- [ ] Cash on Delivery available
- [ ] Online payment options (if implemented)
- [ ] Select payment method

#### Place Order

- [ ] Tap "Place Order" button
- [ ] Loading indicator shows
- [ ] Order processes
- [ ] Confirmation screen appears
- [ ] Order number generated (NN-XXXXX)
- [ ] Order details displayed

**✅ Pass Criteria:** Complete checkout without errors

---

### Phase 8: Order History (10 min)

#### View Orders

- [ ] Navigate to Profile tab
- [ ] Tap "My Orders" or similar
- [ ] Orders screen loads
- [ ] Recent order visible
- [ ] Order details shown:
  - [ ] Order number
  - [ ] Date/time
  - [ ] Total amount
  - [ ] Status
  - [ ] Items count

#### Order Details

- [ ] Tap an order
- [ ] Order detail screen opens
- [ ] All order information visible
- [ ] Items list shown
- [ ] Delivery address shown
- [ ] Payment method shown
- [ ] Status visible

**✅ Pass Criteria:** Orders save and display correctly

---

### Phase 9: Profile Management (10 min)

#### View Profile

- [ ] Profile tab shows user info
- [ ] Phone number displayed
- [ ] Email (if added)
- [ ] Name (if set)

#### Edit Profile

- [ ] Tap "Edit Profile" (if available)
- [ ] Can update name
- [ ] Can update email
- [ ] Save changes
- [ ] Changes persist

#### Address Management

- [ ] View saved addresses
- [ ] Add new address
- [ ] Edit existing address
- [ ] Delete address
- [ ] Set default address

**✅ Pass Criteria:** Profile updates save correctly

---

### Phase 10: Performance & UX (15 min)

#### Performance

- [ ] App feels responsive
- [ ] Scrolling is smooth (60 fps)
- [ ] Images load quickly
- [ ] No lag when navigating
- [ ] Transitions are smooth
- [ ] No memory warnings

#### Network Conditions

- [ ] Turn on airplane mode
- [ ] App shows offline message
- [ ] Turn off airplane mode
- [ ] App reconnects
- [ ] Data reloads

#### Edge Cases

- [ ] What happens with empty cart checkout?
- [ ] What if no location permission?
- [ ] What if OTP fails?
- [ ] What if product out of stock?
- [ ] What if network timeout?

**✅ Pass Criteria:** App handles errors gracefully

---

## 🐛 Bug Tracking

Use this section to note any bugs found:

### Critical Bugs (App Crashes/Can't Proceed)

```
1. 
2. 
3. 
```

### Major Bugs (Feature Broken)

```
1. 
2. 
3. 
```

### Minor Bugs (UI/UX Issues)

```
1. 
2. 
3. 
```

### Suggestions/Improvements

```
1. 
2. 
3. 
```

---

## 📊 Test Results Summary

| Phase           | Status         | Time | Notes |
| --------------- | -------------- | ---- | ----- |
| 1. App Launch   | ⬜ Not Started |      |       |
| 2. Location     | ⬜ Not Started |      |       |
| 3. Products     | ⬜ Not Started |      |       |
| 4. Cart         | ⬜ Not Started |      |       |
| 5. Search       | ⬜ Not Started |      |       |
| 6. Auth         | ⬜ Not Started |      |       |
| 7. Checkout     | ⬜ Not Started |      |       |
| 8. Orders       | ⬜ Not Started |      |       |
| 9. Profile      | ⬜ Not Started |      |       |
| 10. Performance | ⬜ Not Started |      |       |

**Legend:**

- ⬜ Not Started
- 🔄 In Progress
- ✅ Passed
- ❌ Failed
- ⚠️ Partial/Issues

---

## 🎯 Success Criteria

### Minimum to Pass (MVP):

- ✅ App launches without crashes
- ✅ Can browse products
- ✅ Can add to cart
- ✅ Cart persists
- ✅ Can place order
- ✅ Location detection works
- ✅ Authentication works

### Nice to Have:

- ✅ All features work smoothly
- ✅ No major bugs
- ✅ Good performance
- ✅ Clean UI/UX

---

## 📝 Notes & Observations

### Positive Observations:

```
- 
- 
```

### Things to Improve:

```
- 
- 
```

### Questions for Developer:

```
- 
- 
```

---

## ⏭️ Next Steps After Testing

Based on test results:

1. **If All Pass:**

   - Proceed to release build
   - Prepare app store assets
   - Submit for review
2. **If Minor Issues:**

   - Document bugs
   - Fix in next sprint
   - Retest affected areas
3. **If Major Issues:**

   - Prioritize critical bugs
   - Fix immediately
   - Full retest required

---

**Tester:** ________________
**Date:** January 18, 2026
**Build Version:** 1.0.0+1
**Test Duration:** ~2-3 hours

---

🎉 **Happy Testing!** Report any issues you find.
