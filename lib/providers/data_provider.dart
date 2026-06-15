import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cooperative.dart';
import '../models/route.dart';
import '../models/transport_unit.dart';
import '../models/driver.dart';
import '../services/api_service.dart';

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

  DataProvider() {
    _loadData();
  }

  // Load data from API and SharedPreferences (for drivers & assignments)
  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Load cooperatives from API
      _cooperatives = await ApiService.getCooperativas();
    } catch (e) {
      debugPrint('Error loading cooperatives from API: $e');
    }

    try {
      // 2. Load routes from API
      _routes = await ApiService.getRoutes();
    } catch (e) {
      debugPrint('Error loading routes from API: $e');
    }

    try {
      // 3. Load vehicles from API
      _units = await ApiService.getVehiculos();
    } catch (e) {
      debugPrint('Error loading vehicles from API: $e');
    }

    try {
      // 4. Load drivers and local assignments from SharedPreferences
      final prefs = await SharedPreferences.getInstance();

      final driversJson = prefs.getString('drivers') ?? '[]';
      final driversList = jsonDecode(driversJson) as List;
      _drivers = driversList
          .map((json) => Driver.fromJson(json as Map<String, dynamic>))
          .toList();

      // Load route and driver assignments cache if any
      final assignmentsJson = prefs.getString('unit_assignments') ?? '{}';
      final Map<String, dynamic> assignments = jsonDecode(assignmentsJson);

      for (int i = 0; i < _units.length; i++) {
        final placa = _units[i].plate;
        if (assignments.containsKey(placa)) {
          final data = assignments[placa] as Map<String, dynamic>;
          _units[i] = _units[i].copyWith(
            driverId: data['driverId'] as String?,
            routeId: data['routeId'] as String?,
          );
        }
      }
    } catch (e) {
      debugPrint('Error loading cached local data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Save local assignments & drivers cache
  Future<void> _saveLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        'drivers',
        jsonEncode(_drivers.map((d) => d.toJson()).toList()),
      );

      final Map<String, dynamic> assignments = {};
      for (final unit in _units) {
        assignments[unit.plate] = {
          'driverId': unit.driverId,
          'routeId': unit.routeId,
        };
      }
      await prefs.setString('unit_assignments', jsonEncode(assignments));
    } catch (e) {
      debugPrint('Error saving local cache: $e');
    }
  }

  // --- Cooperative CRUD ---

  Future<void> addCooperative({
    required String id,
    required String name,
    required String description,
    required String location,
    required String schedule,
  }) async {
    final cooperative = Cooperative(
      id: id,
      name: name,
      description: description,
      location: location,
      schedule: schedule,
      createdAt: DateTime.now(),
    );

    _isLoading = true;
    notifyListeners();

    try {
      final created = await ApiService.createCooperativa(cooperative);
      _cooperatives.add(created);
    } catch (e) {
      debugPrint('Error creating cooperative: $e');
      // local fallback if offline/failed
      _cooperatives.add(cooperative);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateCooperative({
    required String id,
    required String name,
    required String description,
    required String location,
    required String schedule,
  }) async {
    final cooperative = Cooperative(
      id: id,
      name: name,
      description: description,
      location: location,
      schedule: schedule,
      createdAt: DateTime.now(),
    );

    _isLoading = true;
    notifyListeners();

    try {
      final updated = await ApiService.updateCooperativa(cooperative);
      final index = _cooperatives.indexWhere((c) => c.id == id);
      if (index != -1) {
        _cooperatives[index] = updated;
      }
    } catch (e) {
      debugPrint('Error updating cooperative: $e');
      // local fallback update
      final index = _cooperatives.indexWhere((c) => c.id == id);
      if (index != -1) {
        _cooperatives[index] = cooperative;
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteCooperative(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.deleteCooperativa(id);
      _cooperatives.removeWhere((c) => c.id == id);
      _routes.removeWhere((r) => r.cooperativeId == id);
      _units.removeWhere((u) => u.cooperativeId == id);
      _drivers.removeWhere((d) => d.cooperativeId == id);
      await _saveLocalCache();
    } catch (e) {
      debugPrint('Error deleting cooperative: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // --- Route CRUD ---

  Future<void> addRoute({
    required String id,
    required String name,
    required String description,
    required int fare,
    required String cooperativeId,
    int? originId,
    int? destinationId,
    List<RouteStop> stops = const [],
  }) async {
    final route = TransportRoute(
      id: id,
      name: name,
      description: description,
      fare: fare,
      origin: stops.isNotEmpty ? stops.first.name : 'Origen',
      destination: stops.isNotEmpty ? stops.last.name : 'Destino',
      originId: originId,
      destinationId: destinationId,
      cooperativeId: cooperativeId,
      stops: stops,
      createdAt: DateTime.now(),
    );

    _isLoading = true;
    notifyListeners();

    try {
      final created = await ApiService.createRoute(route);
      _routes.add(created);
    } catch (e) {
      debugPrint('Error creating route: $e');
      _routes.add(route);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateRoute({
    required String id,
    required String name,
    required String description,
    required int fare,
    required String cooperativeId,
    int? originId,
    int? destinationId,
    List<RouteStop> stops = const [],
  }) async {
    final route = TransportRoute(
      id: id,
      name: name,
      description: description,
      fare: fare,
      origin: stops.isNotEmpty ? stops.first.name : 'Origen',
      destination: stops.isNotEmpty ? stops.last.name : 'Destino',
      originId: originId,
      destinationId: destinationId,
      cooperativeId: cooperativeId,
      stops: stops,
      createdAt: DateTime.now(),
    );

    _isLoading = true;
    notifyListeners();

    try {
      final updated = await ApiService.updateRoute(route);
      final index = _routes.indexWhere((r) => r.id == id);
      if (index != -1) {
        _routes[index] = updated;
      }
    } catch (e) {
      debugPrint('Error updating route: $e');
      final index = _routes.indexWhere((r) => r.id == id);
      if (index != -1) {
        _routes[index] = route;
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteRoute(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.deleteRoute(id);
      _routes.removeWhere((r) => r.id == id);
      for (int i = 0; i < _units.length; i++) {
        if (_units[i].routeId == id) {
          _units[i] = _units[i].copyWith(routeId: null);
        }
      }
      await _saveLocalCache();
    } catch (e) {
      debugPrint('Error deleting route: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  List<TransportRoute> getRoutesByCooperative(String cooperativeId) {
    return _routes.where((r) => r.cooperativeId == cooperativeId).toList();
  }

  // --- Driver CRUD ---

  Future<void> addDriver(String name, String phone, String cooperativeId) async {
    final driver = Driver(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      phone: phone,
      cooperativeId: cooperativeId,
      createdAt: DateTime.now(),
    );

    _drivers.add(driver);
    await _saveLocalCache();
    notifyListeners();
  }

  Future<void> updateDriver(String id, String name, String phone) async {
    final index = _drivers.indexWhere((d) => d.id == id);
    if (index != -1) {
      _drivers[index] = _drivers[index].copyWith(
        name: name,
        phone: phone,
      );
      await _saveLocalCache();
      notifyListeners();
    }
  }

  Future<void> deleteDriver(String id) async {
    _drivers.removeWhere((d) => d.id == id);
    for (int i = 0; i < _units.length; i++) {
      if (_units[i].driverId == id) {
        _units[i] = _units[i].copyWith(driverId: null);
      }
    }
    await _saveLocalCache();
    notifyListeners();
  }

  List<Driver> getDriversByCooperative(String cooperativeId) {
    return _drivers.where((d) => d.cooperativeId == cooperativeId).toList();
  }

  // --- Transport Unit CRUD ---

  Future<void> addTransportUnit({
    required String plate,
    required String model,
    required String color,
    required String yearOfManufacture,
    required String cooperativeId,
  }) async {
    final unit = TransportUnit(
      id: plate,
      plate: plate,
      model: model,
      color: color,
      yearOfManufacture: yearOfManufacture,
      cooperativeId: cooperativeId,
      createdAt: DateTime.now(),
    );

    _isLoading = true;
    notifyListeners();

    try {
      final created = await ApiService.registerVehiculo(unit);
      _units.add(created);
      await _saveLocalCache();
    } catch (e) {
      debugPrint('Error registering vehicle: $e');
      _units.add(unit);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateTransportUnit({
    required String id,
    required String model,
    required String color,
    required String yearOfManufacture,
    required String cooperativeId,
    String? routeId,
    String? driverId,
  }) async {
    final unit = TransportUnit(
      id: id,
      plate: id,
      model: model,
      color: color,
      yearOfManufacture: yearOfManufacture,
      cooperativeId: cooperativeId,
      driverId: driverId,
      routeId: routeId,
      createdAt: DateTime.now(),
    );

    _isLoading = true;
    notifyListeners();

    try {
      final updated = await ApiService.updateVehiculo(unit);
      final index = _units.indexWhere((u) => u.id == id);
      if (index != -1) {
        _units[index] = updated.copyWith(
          driverId: driverId,
          routeId: routeId,
        );
      }
      await _saveLocalCache();
    } catch (e) {
      debugPrint('Error updating vehicle: $e');
      final index = _units.indexWhere((u) => u.id == id);
      if (index != -1) {
        _units[index] = unit;
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> assignDriverToUnit(String unitId, String? driverId) async {
    final index = _units.indexWhere((u) => u.id == unitId);
    if (index != -1) {
      _units[index] = _units[index].copyWith(driverId: driverId);
      await _saveLocalCache();
      notifyListeners();
    }
  }

  Future<void> assignRouteToUnit(String unitId, String? routeId) async {
    final index = _units.indexWhere((u) => u.id == unitId);
    if (index != -1) {
      _units[index] = _units[index].copyWith(routeId: routeId);
      await _saveLocalCache();
      notifyListeners();
    }
  }

  Future<void> deleteTransportUnit(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.deleteVehiculo(id);
      _units.removeWhere((u) => u.id == id);
      await _saveLocalCache();
    } catch (e) {
      debugPrint('Error deleting vehicle: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  List<TransportUnit> getUnitsByRoute(String routeId) {
    return _units.where((u) => u.routeId == routeId).toList();
  }

  List<TransportUnit> getUnitsByCooperative(String cooperativeId) {
    return _units.where((u) => u.cooperativeId == cooperativeId).toList();
  }

  int getTotalRoutes() => _routes.length;
  int getTotalUnits() => _units.length;

  int getRouteCountForCooperative(String cooperativeId) {
    return _routes.where((r) => r.cooperativeId == cooperativeId).length;
  }

  int getUnitCountForRoute(String routeId) {
    return _units.where((u) => u.routeId == routeId).length;
  }
}
