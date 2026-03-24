class User {
  final String id;
  final String name;
  final String? username;
  final String? email;
  final String? phone;
  final String userType;
  final bool isActive;

  User({
    required this.id,
    required this.name,
    this.username,
    this.email,
    this.phone,
    this.userType = 'customer',
    this.isActive = true,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      username: json['username'],
      email: json['email'],
      phone: json['phone'],
      userType: json['userType'] ?? 'customer',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'phone': phone,
      'userType': userType,
      'isActive': isActive,
    };
  }
}
