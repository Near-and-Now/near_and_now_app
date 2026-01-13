class OrderItem {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String? image;

  OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.image,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id'] as String? ?? 'unknown',
      name: json['name'] as String? ?? 'Unknown Product',
      price: _parseDouble(json['price']),
      quantity: (json['quantity'] as int?) ?? 1,
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'image': image,
    };
  }

  double get total => price * quantity;

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class ShippingAddress {
  final String address;
  final String city;
  final String state;
  final String pincode;

  ShippingAddress({
    String? address,
    String? city,
    String? state,
    String? pincode,
  }) : address = address ?? 'Not provided',
       city = city ?? 'Not provided',
       state = state ?? 'Not provided',
       pincode = pincode ?? '000000';

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
    };
  }

  String get fullAddress => '$address, $city, $state - $pincode';
}

enum OrderStatus {
  placed,
  confirmed,
  shipped,
  delivered,
  cancelled;

  String get displayName {
    switch (this) {
      case OrderStatus.placed:
        return 'Placed';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded;

  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }
}

class Order {
  final String id;
  final String? userId;
  final String customerName;
  final String? customerEmail;
  final String? customerPhone;
  final OrderStatus orderStatus;
  final PaymentStatus paymentStatus;
  final String paymentMethod;
  final double orderTotal;
  final double? subtotal;
  final double? deliveryFee;
  final List<OrderItem>? items;
  final int? itemsCount;
  final ShippingAddress? shippingAddress;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? orderNumber;

  Order({
    required this.id,
    this.userId,
    String? customerName,
    this.customerEmail,
    this.customerPhone,
    required this.orderStatus,
    required this.paymentStatus,
    String? paymentMethod,
    required this.orderTotal,
    this.subtotal,
    this.deliveryFee,
    this.items,
    this.itemsCount,
    this.shippingAddress,
    required this.createdAt,
    this.updatedAt,
    this.orderNumber,
  }) : customerName = customerName ?? 'Guest Customer',
       paymentMethod = paymentMethod ?? 'Cash on Delivery';

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      customerName: json['customer_name'] as String?,
      customerEmail: json['customer_email'] as String?,
      customerPhone: json['customer_phone'] as String?,
      orderStatus: OrderStatus.values.firstWhere(
        (e) => e.name == json['order_status'],
        orElse: () => OrderStatus.placed,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == json['payment_status'],
        orElse: () => PaymentStatus.pending,
      ),
      paymentMethod: json['payment_method'] as String?,
      orderTotal: _parseDouble(json['order_total']),
      subtotal: json['subtotal'] != null ? _parseDouble(json['subtotal']) : null,
      deliveryFee:
          json['delivery_fee'] != null ? _parseDouble(json['delivery_fee']) : null,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
      itemsCount: json['items_count'] as int?,
      shippingAddress: json['shipping_address'] != null
          ? ShippingAddress.fromJson(
              json['shipping_address'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      orderNumber: json['order_number'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'customer_name': customerName,
      'customer_email': customerEmail,
      'customer_phone': customerPhone,
      'order_status': orderStatus.name,
      'payment_status': paymentStatus.name,
      'payment_method': paymentMethod,
      'order_total': orderTotal,
      'subtotal': subtotal,
      'delivery_fee': deliveryFee,
      'items': items?.map((item) => item.toJson()).toList(),
      'items_count': itemsCount,
      'shipping_address': shippingAddress?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'order_number': orderNumber,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

