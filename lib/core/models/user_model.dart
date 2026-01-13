class UserModel {
  final String id;
  final String? phone;
  final String? email;
  final String? name;
  final String? avatarUrl;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    this.phone,
    this.email,
    this.name,
    this.avatarUrl,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      name: json['name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'email': email,
      'name': name,
      'avatar_url': avatarUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  String get displayName => name ?? phone ?? email ?? 'User';

  UserModel copyWith({
    String? id,
    String? phone,
    String? email,
    String? name,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

