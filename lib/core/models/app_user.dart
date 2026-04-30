class AppUser {
  final int id;
  final String role;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String? dob;
  final String? businessType;
  final String? region;
  final String? city;
  final String passwordSalt;
  final String passwordHash;
  final String createdAt;

  const AppUser({
    required this.id,
    required this.role,
    required this.name,
    required this.email,
    required this.passwordSalt,
    required this.passwordHash,
    required this.createdAt,
    this.phone,
    this.address,
    this.dob,
    this.businessType,
    this.region,
    this.city,
  });

  AppUser copyWith({
    int? id,
    String? role,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? dob,
    String? businessType,
    String? region,
    String? city,
    String? passwordSalt,
    String? passwordHash,
    String? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      role: role ?? this.role,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      dob: dob ?? this.dob,
      businessType: businessType ?? this.businessType,
      region: region ?? this.region,
      city: city ?? this.city,
      passwordSalt: passwordSalt ?? this.passwordSalt,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'role': role,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'dob': dob,
      'business_type': businessType,
      'region': region,
      'city': city,
      'password_salt': passwordSalt,
      'password_hash': passwordHash,
      'created_at': createdAt,
    };
  }

  static AppUser fromMap(Map<String, Object?> map) {
    return AppUser(
      id: map['id'] as int,
      role: map['role'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      dob: map['dob'] as String?,
      businessType: map['business_type'] as String?,
      region: map['region'] as String?,
      city: map['city'] as String?,
      passwordSalt: map['password_salt'] as String,
      passwordHash: map['password_hash'] as String,
      createdAt: map['created_at'] as String,
    );
  }
}
