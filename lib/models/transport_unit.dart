class TransportUnit {
  final String id;
  final String unitNumber;
  final String plate;
  final int capacity;
  final String driver;
  final String routeId;
  final DateTime createdAt;

  TransportUnit({
    required this.id,
    required this.unitNumber,
    required this.plate,
    required this.capacity,
    required this.driver,
    required this.routeId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'unitNumber': unitNumber,
      'plate': plate,
      'capacity': capacity,
      'driver': driver,
      'routeId': routeId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TransportUnit.fromJson(Map<String, dynamic> json) {
    return TransportUnit(
      id: json['id'] as String,
      unitNumber: json['unitNumber'] as String,
      plate: json['plate'] as String,
      capacity: json['capacity'] as int,
      driver: json['driver'] as String,
      routeId: json['routeId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  TransportUnit copyWith({
    String? id,
    String? unitNumber,
    String? plate,
    int? capacity,
    String? driver,
    String? routeId,
    DateTime? createdAt,
  }) {
    return TransportUnit(
      id: id ?? this.id,
      unitNumber: unitNumber ?? this.unitNumber,
      plate: plate ?? this.plate,
      capacity: capacity ?? this.capacity,
      driver: driver ?? this.driver,
      routeId: routeId ?? this.routeId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
