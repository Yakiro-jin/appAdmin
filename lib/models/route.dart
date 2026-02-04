class TransportRoute {
  final String id;
  final String name;
  final String origin;
  final String destination;
  final String cooperativeId;
  final DateTime createdAt;

  TransportRoute({
    required this.id,
    required this.name,
    required this.origin,
    required this.destination,
    required this.cooperativeId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'origin': origin,
      'destination': destination,
      'cooperativeId': cooperativeId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TransportRoute.fromJson(Map<String, dynamic> json) {
    return TransportRoute(
      id: json['id'] as String,
      name: json['name'] as String,
      origin: json['origin'] as String,
      destination: json['destination'] as String,
      cooperativeId: json['cooperativeId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  TransportRoute copyWith({
    String? id,
    String? name,
    String? origin,
    String? destination,
    String? cooperativeId,
    DateTime? createdAt,
  }) {
    return TransportRoute(
      id: id ?? this.id,
      name: name ?? this.name,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      cooperativeId: cooperativeId ?? this.cooperativeId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
