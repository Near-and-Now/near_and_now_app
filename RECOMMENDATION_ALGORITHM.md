# Product Recommendations - "You Might Also Like"

## Overview

The "You Might Also Like" section on the checkout page shows products from the same categories as items in the user's cart. It's a simple, fast, and effective way to suggest related products.

## How It Works

### Simple Algorithm

1. **Get cart categories** - Extract categories from all items in the cart
2. **Filter products** - Find all in-stock products from those same categories
3. **Shuffle for variety** - Randomize the order
4. **Return 10 products** - Take the first 10 products
5. **Exclude cart items** - Don't show products already in the cart

### Example

**Cart contains:**
- Milk (Dairy)
- Bread (Bakery)
- Bananas (Fruits)

**Recommendations will show:**
- Other Dairy products (Cheese, Yogurt, Butter, etc.)
- Other Bakery products (Croissants, Buns, etc.)
- Other Fruits (Apples, Oranges, Grapes, etc.)

**Up to 10 products total**, shuffled for variety.

## UI Design

The section matches the rest of the checkout page:

- **Header**: "You Might Also Like" with heart icon
- **Layout**: Horizontal scrollable list
- **Product Cards**: Standard ProductCard widget (160px wide)
- **Styling**: White background, consistent padding
- **Icon**: Heart outline icon in primary color circle

## Location

Appears on the **Checkout Screen** after:
1. Delivery Location
2. Cart Items
3. Payment Method

## Technical Details

### Files
- **Provider**: `lib/features/products/providers/products_provider.dart`
  - `relatedProductsProvider`
  
- **UI**: `lib/features/checkout/screens/checkout_screen.dart`
  - `_buildSuggestedProductsSection()`

### Performance
- Fast and lightweight (no complex calculations)
- Runs asynchronously (non-blocking)
- Cached by Riverpod
- Only loads once per checkout visit

### Edge Cases
- **Empty cart**: Shows first 10 products from database
- **Few matching products**: Supplements with products from other categories
- **All products in cart**: Section is hidden
- **No products in database**: Section is hidden

## Testing

1. **Add items to cart** from different categories
2. **Go to checkout page**
3. **Scroll down** past Payment Method
4. **See "You Might Also Like" section** with 10 products

## Benefits

✅ **Simple** - Easy to understand and maintain
✅ **Fast** - No complex calculations
✅ **Relevant** - Shows products from same categories
✅ **Consistent** - Matches page design
✅ **Clean** - Excludes items already in cart
✅ **Reliable** - Works with any cart contents

## Summary

A straightforward recommendation system that shows products from the same categories as cart items, presented in a clean, scrollable horizontal list that matches the checkout page design.
