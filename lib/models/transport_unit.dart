class TransportUnit {
  final String id;
  final String unitNumber;
  final String plate;
  final int capacity;
  final String? driverId;
  final String cooperativeId;
  final String? routeId;
  final DateTime createdAt;

  TransportUnit({
    required this.id,
    required this.unitNumber,
    required this.plate,
    required this.capacity,
    this.driverId,
    required this.cooperativeId,
    this.routeId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'unitNumber': unitNumber,
      'plate': plate,
      'capacity': capacity,
      'driverId': driverId,
      'cooperativeId': cooperativeId,
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
      driverId: json['driverId'] as String?,
      cooperativeId: json['cooperativeId'] as String? ?? '',
      routeId: json['routeId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  TransportUnit copyWith({
    String? id,
    String? unitNumber,
    String? plate,
    int? capacity,
    String? driverId,
    String? cooperativeId,
    String? routeId,
    DateTime? createdAt,
  }) {
    return TransportUnit(
      id: id ?? this.id,
      unitNumber: unitNumber ?? this.unitNumber,
      plate: plate ?? this.plate,
      capacity: capacity ?? this.capacity,
      driverId: driverId ?? this.driverId,
      cooperativeId: cooperativeId ?? this.cooperativeId,
      routeId: routeId ?? this.routeId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
