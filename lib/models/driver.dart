class Driver {
  final String id;
  final String name;
  final String phone;
  final String cooperativeId;
  final DateTime createdAt;

  Driver({
    required this.id,
    required this.name,
    required this.phone,
    required this.cooperativeId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'cooperativeId': cooperativeId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      cooperativeId: json['cooperativeId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Driver copyWith({
    String? id,
    String? name,
    String? phone,
    String? cooperativeId,
    DateTime? createdAt,
  }) {
    return Driver(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      cooperativeId: cooperativeId ?? this.cooperativeId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
