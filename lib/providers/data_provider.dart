import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/cooperative.dart';
import '../models/route.dart';
import '../models/transport_unit.dart';
import '../models/driver.dart';

class DataProvider with ChangeNotifier {
  List<Cooperative> _cooperatives = [];
  List<TransportRoute> _routes = [];
  List<TransportUnit> _units = [];
  List<Driver> _drivers = [];
  bool _isLoading = false;

  List<Cooperative> get cooperatives => _cooperatives;
  List<TransportRoute> get routes => _routes;
  List<TransportUnit> get units => _units;
  List<Driver> get drivers => _drivers;
  bool get isLoading => _isLoading;

  final _uuid = const Uuid();

  DataProvider() {
    _loadData();
  }

  // Load data from SharedPreferences
  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load cooperatives
      final cooperativesJson = prefs.getString('cooperatives') ?? '[]';
      final cooperativesList = jsonDecode(cooperativesJson) as List;
      _cooperatives = cooperativesList
          .map((json) => Cooperative.fromJson(json as Map<String, dynamic>))
          .toList();

      // Load routes
      final routesJson = prefs.getString('routes') ?? '[]';
      final routesList = jsonDecode(routesJson) as List;
      _routes = routesList
          .map((json) => TransportRoute.fromJson(json as Map<String, dynamic>))
          .toList();

      // Load drivers
      final driversJson = prefs.getString('drivers') ?? '[]';
      final driversList = jsonDecode(driversJson) as List;
      _drivers = driversList
          .map((json) => Driver.fromJson(json as Map<String, dynamic>))
          .toList();

      // Load units
      final unitsJson = prefs.getString('units') ?? '[]';
      final unitsList = jsonDecode(unitsJson) as List;
      _units = unitsList
          .map((json) => TransportUnit.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Save data to SharedPreferences
  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        'cooperatives',
        jsonEncode(_cooperatives.map((c) => c.toJson()).toList()),
      );

      await prefs.setString(
        'routes',
        jsonEncode(_routes.map((r) => r.toJson()).toList()),
      );

      await prefs.setString(
        'drivers',
        jsonEncode(_drivers.map((d) => d.toJson()).toList()),
      );

      await prefs.setString(
        'units',
        jsonEncode(_units.map((u) => u.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('Error saving data: $e');
    }
  }

  // Cooperative CRUD
  Future<void> addCooperative(String name, String description) async {
    final cooperative = Cooperative(
      id: _uuid.v4(),
      name: name,
      description: description,
      createdAt: DateTime.now(),
    );

    _cooperatives.add(cooperative);
    await _saveData();
    notifyListeners();
  }

  Future<void> updateCooperative(
      String id, String name, String description) async {
    final index = _cooperatives.indexWhere((c) => c.id == id);
    if (index != -1) {
      _cooperatives[index] = _cooperatives[index].copyWith(
        name: name,
        description: description,
      );
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> deleteCooperative(String id) async {
    _cooperatives.removeWhere((c) => c.id == id);
    
    // Also delete related routes, units, and drivers
    _routes.removeWhere((r) => r.cooperativeId == id);
    _units.removeWhere((u) => u.cooperativeId == id);
    _drivers.removeWhere((d) => d.cooperativeId == id);

    await _saveData();
    notifyListeners();
  }

  // Route CRUD
  Future<void> addRoute(String name, String origin, String destination,
      String cooperativeId, List<RouteStop> stops) async {
    final route = TransportRoute(
      id: _uuid.v4(),
      name: name,
      origin: origin,
      destination: destination,
      cooperativeId: cooperativeId,
      stops: stops,
      createdAt: DateTime.now(),
    );

    _routes.add(route);
    await _saveData();
    notifyListeners();
  }

  Future<void> updateRoute(String id, String name, String origin,
      String destination, List<RouteStop> stops) async {
    final index = _routes.indexWhere((r) => r.id == id);
    if (index != -1) {
      _routes[index] = _routes[index].copyWith(
        name: name,
        origin: origin,
        destination: destination,
        stops: stops,
      );
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> deleteRoute(String id) async {
    _routes.removeWhere((r) => r.id == id);
    // Unassign routeId from units belonging to this route
    for (int i = 0; i < _units.length; i++) {
      if (_units[i].routeId == id) {
        _units[i] = _units[i].copyWith(routeId: null);
      }
    }
    await _saveData();
    notifyListeners();
  }

  List<TransportRoute> getRoutesByCooperative(String cooperativeId) {
    return _routes.where((r) => r.cooperativeId == cooperativeId).toList();
  }

  // Driver CRUD
  Future<void> addDriver(String name, String phone, String cooperativeId) async {
    final driver = Driver(
      id: _uuid.v4(),
      name: name,
      phone: phone,
      cooperativeId: cooperativeId,
      createdAt: DateTime.now(),
    );

    _drivers.add(driver);
    await _saveData();
    notifyListeners();
  }

  Future<void> updateDriver(String id, String name, String phone) async {
    final index = _drivers.indexWhere((d) => d.id == id);
    if (index != -1) {
      _drivers[index] = _drivers[index].copyWith(
        name: name,
        phone: phone,
      );
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> deleteDriver(String id) async {
    _drivers.removeWhere((d) => d.id == id);
    // Unassign driver from units
    for (int i = 0; i < _units.length; i++) {
      if (_units[i].driverId == id) {
        _units[i] = _units[i].copyWith(driverId: null);
      }
    }
    await _saveData();
    notifyListeners();
  }

  List<Driver> getDriversByCooperative(String cooperativeId) {
    return _drivers.where((d) => d.cooperativeId == cooperativeId).toList();
  }

  // Transport Unit CRUD
  Future<void> addTransportUnit(
    String unitNumber,
    String plate,
    int capacity,
    String cooperativeId, {
    String? routeId,
    String? driverId,
  }) async {
    final unit = TransportUnit(
      id: _uuid.v4(),
      unitNumber: unitNumber,
      plate: plate,
      capacity: capacity,
      driverId: driverId,
      cooperativeId: cooperativeId,
      routeId: routeId,
      createdAt: DateTime.now(),
    );

    _units.add(unit);
    await _saveData();
    notifyListeners();
  }

  Future<void> updateTransportUnit(
    String id,
    String unitNumber,
    String plate,
    int capacity, {
    String? routeId,
    String? driverId,
    String? cooperativeId,
  }) async {
    final index = _units.indexWhere((u) => u.id == id);
    if (index != -1) {
      _units[index] = _units[index].copyWith(
        unitNumber: unitNumber,
        plate: plate,
        capacity: capacity,
        routeId: routeId,
        driverId: driverId,
        cooperativeId: cooperativeId ?? _units[index].cooperativeId,
      );
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> assignDriverToUnit(String unitId, String? driverId) async {
    final index = _units.indexWhere((u) => u.id == unitId);
    if (index != -1) {
      _units[index] = _units[index].copyWith(driverId: driverId);
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> assignRouteToUnit(String unitId, String? routeId) async {
    final index = _units.indexWhere((u) => u.id == unitId);
    if (index != -1) {
      _units[index] = _units[index].copyWith(routeId: routeId);
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> deleteTransportUnit(String id) async {
    _units.removeWhere((u) => u.id == id);
    await _saveData();
    notifyListeners();
  }

  List<TransportUnit> getUnitsByRoute(String routeId) {
    return _units.where((u) => u.routeId == routeId).toList();
  }

  List<TransportUnit> getUnitsByCooperative(String cooperativeId) {
    return _units.where((u) => u.cooperativeId == cooperativeId).toList();
  }

  // Statistics
  int getTotalRoutes() => _routes.length;
  int getTotalUnits() => _units.length;

  int getRouteCountForCooperative(String cooperativeId) {
    return _routes.where((r) => r.cooperativeId == cooperativeId).length;
  }

  int getUnitCountForRoute(String routeId) {
    return _units.where((u) => u.routeId == routeId).length;
  }
}
