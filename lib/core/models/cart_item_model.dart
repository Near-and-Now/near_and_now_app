import 'product_model.dart';

class CartItem {
  final Product product;
  final int quantity;
  final double? customWeight; // For loose items

  CartItem({
    required this.product,
    required this.quantity,
    this.customWeight,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      customWeight: json['custom_weight'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'custom_weight': customWeight,
    };
  }

  double get totalPrice {
    if (product.isLoose && customWeight != null) {
      return product.price * customWeight!;
    }
    return product.price * quantity;
  }

  CartItem copyWith({
    Product? product,
    int? quantity,
    double? customWeight,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      customWeight: customWeight ?? this.customWeight,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && other.product.id == product.id;
  }

  @override
  int get hashCode => product.id.hashCode;
}

