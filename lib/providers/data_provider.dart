import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/cooperative.dart';
import '../models/route.dart';
import '../models/transport_unit.dart';

class DataProvider with ChangeNotifier {
  List<Cooperative> _cooperatives = [];
  List<TransportRoute> _routes = [];
  List<TransportUnit> _units = [];
  bool _isLoading = false;

  List<Cooperative> get cooperatives => _cooperatives;
  List<TransportRoute> get routes => _routes;
  List<TransportUnit> get units => _units;
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
    // Also delete related routes and units
    final routeIds =
        _routes.where((r) => r.cooperativeId == id).map((r) => r.id).toList();
    _routes.removeWhere((r) => r.cooperativeId == id);
    _units.removeWhere((u) => routeIds.contains(u.routeId));

    await _saveData();
    notifyListeners();
  }

  // Route CRUD
  Future<void> addRoute(String name, String origin, String destination,
      String cooperativeId) async {
    final route = TransportRoute(
      id: _uuid.v4(),
      name: name,
      origin: origin,
      destination: destination,
      cooperativeId: cooperativeId,
      createdAt: DateTime.now(),
    );

    _routes.add(route);
    await _saveData();
    notifyListeners();
  }

  Future<void> updateRoute(
      String id, String name, String origin, String destination) async {
    final index = _routes.indexWhere((r) => r.id == id);
    if (index != -1) {
      _routes[index] = _routes[index].copyWith(
        name: name,
        origin: origin,
        destination: destination,
      );
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> deleteRoute(String id) async {
    _routes.removeWhere((r) => r.id == id);
    // Also delete related units
    _units.removeWhere((u) => u.routeId == id);

    await _saveData();
    notifyListeners();
  }

  List<TransportRoute> getRoutesByCooperative(String cooperativeId) {
    return _routes.where((r) => r.cooperativeId == cooperativeId).toList();
  }

  // Transport Unit CRUD
  Future<void> addTransportUnit(
    String unitNumber,
    String plate,
    int capacity,
    String driver,
    String routeId,
  ) async {
    final unit = TransportUnit(
      id: _uuid.v4(),
      unitNumber: unitNumber,
      plate: plate,
      capacity: capacity,
      driver: driver,
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
    int capacity,
    String driver,
  ) async {
    final index = _units.indexWhere((u) => u.id == id);
    if (index != -1) {
      _units[index] = _units[index].copyWith(
        unitNumber: unitNumber,
        plate: plate,
        capacity: capacity,
        driver: driver,
      );
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
