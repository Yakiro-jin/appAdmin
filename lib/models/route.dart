class RouteStop {
  final String name;
  final double latitude;
  final double longitude;

  RouteStop({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory RouteStop.fromJson(Map<String, dynamic> json) {
    return RouteStop(
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}

class TransportRoute {
  final String id;
  final String name;
  final String origin;
  final String destination;
  final String cooperativeId;
  final List<RouteStop> stops;
  final DateTime createdAt;

  TransportRoute({
    required this.id,
    required this.name,
    required this.origin,
    required this.destination,
    required this.cooperativeId,
    required this.stops,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'origin': origin,
      'destination': destination,
      'cooperativeId': cooperativeId,
      'stops': stops.map((s) => s.toJson()).toList(),
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
      stops: (json['stops'] as List? ?? [])
          .map((s) => RouteStop.fromJson(s as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  TransportRoute copyWith({
    String? id,
    String? name,
    String? origin,
    String? destination,
    String? cooperativeId,
    List<RouteStop>? stops,
    DateTime? createdAt,
  }) {
    return TransportRoute(
      id: id ?? this.id,
      name: name ?? this.name,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      cooperativeId: cooperativeId ?? this.cooperativeId,
      stops: stops ?? this.stops,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
