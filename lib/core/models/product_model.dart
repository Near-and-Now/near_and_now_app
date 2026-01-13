class Product {
  final String id;
  final String name;
  final double price;
  final double? originalPrice;
  final String? description;
  final String? image;
  final String? imageUrl;
  final List<String>? images;
  final String category;
  final bool inStock;
  final double? rating;
  final String? size;
  final String? weight;
  final String? unit;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isLoose;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    this.description,
    this.image,
    this.imageUrl,
    this.images,
    required this.category,
    required this.inStock,
    this.rating,
    this.size,
    this.weight,
    this.unit,
    this.createdAt,
    this.updatedAt,
    this.isLoose = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      price: _parseDouble(json['price']),
      originalPrice: json['original_price'] != null
          ? _parseDouble(json['original_price'])
          : null,
      description: json['description'] as String?,
      image: json['image'] as String?,
      imageUrl: json['image_url'] as String?,
      images: json['images'] != null
          ? List<String>.from(json['images'] as List)
          : null,
      category: json['category'] as String,
      inStock: json['in_stock'] as bool? ?? true,
      rating: json['rating'] != null ? _parseDouble(json['rating']) : null,
      size: json['size'] as String?,
      weight: json['weight'] as String?,
      unit: json['unit'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      isLoose: json['isLoose'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'original_price': originalPrice,
      'description': description,
      'image': image,
      'image_url': imageUrl,
      'images': images,
      'category': category,
      'in_stock': inStock,
      'rating': rating,
      'size': size,
      'weight': weight,
      'unit': unit,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'isLoose': isLoose,
    };
  }

  String get displayImage => imageUrl ?? image ?? '';

  bool get hasDiscount =>
      originalPrice != null && originalPrice! > price;

  double? get discountPercentage {
    if (!hasDiscount) return null;
    return ((originalPrice! - price) / originalPrice!) * 100;
  }

  Product copyWith({
    String? id,
    String? name,
    double? price,
    double? originalPrice,
    String? description,
    String? image,
    String? imageUrl,
    List<String>? images,
    String? category,
    bool? inStock,
    double? rating,
    String? size,
    String? weight,
    String? unit,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isLoose,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      description: description ?? this.description,
      image: image ?? this.image,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      category: category ?? this.category,
      inStock: inStock ?? this.inStock,
      rating: rating ?? this.rating,
      size: size ?? this.size,
      weight: weight ?? this.weight,
      unit: unit ?? this.unit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isLoose: isLoose ?? this.isLoose,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

