import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/cooperative.dart';
import '../../models/transport_unit.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/route_card.dart';
import '../../widgets/transport_unit_card.dart';
import '../routes/route_form_screen.dart';
import '../routes/route_detail_screen.dart';
import 'cooperative_form_screen.dart';
import 'driver_form_screen.dart';
import '../units/transport_unit_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  String? _selectedCooperativeId;
  int _activeTabIndex = 0;

  @override
  void initState() {
    super.initState();
    // TabController is initialized in didChangeDependencies or build when cooperatives count is known
  }

  void _initTabController() {
    if (_tabController == null) {
      _tabController = TabController(length: 3, vsync: this);
      _tabController!.addListener(() {
        if (_tabController!.index != _activeTabIndex) {
          setState(() {
            _activeTabIndex = _tabController!.index;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _showDeleteCooperativeDialog(BuildContext context, Cooperative cooperative) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
            '¿Está seguro de eliminar la cooperativa "${cooperative.name}"? Esto también eliminará todas sus rutas, buses y choferes.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<DataProvider>().deleteCooperative(cooperative.id);
              Navigator.of(ctx).pop();
              setState(() {
                _selectedCooperativeId = null;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cooperativa eliminada')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showCooperativeSelectionDialog(BuildContext context, DataProvider dataProvider) {
    final cooperatives = dataProvider.cooperatives;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            'Seleccionar Cooperativa',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: cooperatives.length,
              itemBuilder: (context, index) {
                final coop = cooperatives[index];
                final isSelected = coop.id == _selectedCooperativeId;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isSelected ? Colors.green.shade100 : Colors.grey.shade100,
                    child: Icon(
                      Icons.business,
                      color: isSelected ? Colors.green.shade800 : Colors.grey.shade700,
                    ),
                  ),
                  title: Text(
                    coop.name,
                    style: GoogleFonts.poppins(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green) : null,
                  onTap: () {
                    setState(() {
                      _selectedCooperativeId = coop.id;
                    });
                    Navigator.pop(ctx);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteRouteDialog(BuildContext context, String routeId, String routeName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirmar eliminación', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(
            '¿Está seguro de eliminar la ruta "$routeName"? Sus unidades dejarán de estar asignadas a esta ruta.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<DataProvider>().deleteRoute(routeId);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ruta eliminada')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteUnitDialog(BuildContext context, String unitId, String unitNumber) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirmar eliminación', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('¿Está seguro de eliminar la unidad "$unitNumber"?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<DataProvider>().deleteTransportUnit(unitId);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Unidad eliminada')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDriverDialog(BuildContext context, String driverId, String driverName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirmar eliminación', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(
            '¿Está seguro de eliminar al chofer "$driverName"? Se desasignará de cualquier unidad.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<DataProvider>().deleteDriver(driverId);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chofer eliminado')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showDriverSelectionDialog(BuildContext context, DataProvider dataProvider, TransportUnit unit, String cooperativeId) {
    final drivers = dataProvider.getDriversByCooperative(cooperativeId);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            'Asignar Chofer a Unidad ${unit.unitNumber}',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: SizedBox(
            width: double.maxFinite,
            child: drivers.isEmpty
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.person_off_rounded, size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No hay choferes registrados en esta cooperativa.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => DriverFormScreen(
                                cooperativeId: cooperativeId,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Registrar Chofer'),
                      ),
                    ],
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: drivers.length,
                    itemBuilder: (context, index) {
                      final driver = drivers[index];
                      final isCurrent = unit.driverId == driver.id;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isCurrent ? Colors.green.shade100 : Colors.grey.shade100,
                          child: Icon(
                            Icons.person,
                            color: isCurrent ? Colors.green.shade800 : Colors.grey.shade700,
                          ),
                        ),
                        title: Text(
                          driver.name,
                          style: GoogleFonts.poppins(
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text('Telf: ${driver.phone}'),
                        trailing: isCurrent ? const Icon(Icons.check_circle, color: Colors.green) : null,
                        onTap: () {
                          dataProvider.assignDriverToUnit(unit.id, driver.id);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Chofer ${driver.name} asignado a la unidad ${unit.unitNumber}')),
                          );
                        },
                      );
                    },
                  ),
          ),
          actions: [
            if (unit.driverId != null && unit.driverId!.isNotEmpty)
              TextButton(
                onPressed: () {
                  dataProvider.assignDriverToUnit(unit.id, null);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Chofer desasignado de la unidad ${unit.unitNumber}')),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Quitar Chofer (Ninguno)'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        final cooperatives = dataProvider.cooperatives;

        if (cooperatives.isEmpty) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(
                'Panel de Control',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18),
              ),
              elevation: 0,
              backgroundColor: const Color(0xFF1A1F2B),
              foregroundColor: Colors.white,
              actions: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  tooltip: 'Opciones',
                  onSelected: (value) {
                    if (value == 'add') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const CooperativeFormScreen(),
                        ),
                      );
                    } else if (value == 'logout') {
                      context.read<AuthProvider>().logout();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'add',
                      child: Row(
                        children: [
                          Icon(Icons.add_business_rounded),
                          SizedBox(width: 8),
                          Text('Agregar cooperativa'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout_rounded),
                          SizedBox(width: 8),
                          Text('Cerrar sesión'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.business_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No hay cooperativas',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Registra una cooperativa para comenzar a gestionar rutas, unidades y conductores.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CooperativeFormScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1F2B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.add_business_rounded),
                      label: Text('Crear Cooperativa', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Handle selected cooperative
        _selectedCooperativeId ??= cooperatives.first.id;

        final matching = cooperatives.where((c) => c.id == _selectedCooperativeId);
        Cooperative activeCooperative;
        if (matching.isNotEmpty) {
          activeCooperative = matching.first;
        } else {
          activeCooperative = cooperatives.first;
          _selectedCooperativeId = activeCooperative.id;
        }

        _initTabController();

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            title: Text(
              activeCooperative.name,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            elevation: 0,
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                tooltip: 'Opciones',
                onSelected: (value) {
                  if (value == 'change') {
                    _showCooperativeSelectionDialog(context, dataProvider);
                  } else if (value == 'add') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CooperativeFormScreen(),
                      ),
                    );
                  } else if (value == 'edit') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CooperativeFormScreen(cooperative: activeCooperative),
                      ),
                    );
                  } else if (value == 'delete') {
                    _showDeleteCooperativeDialog(context, activeCooperative);
                  } else if (value == 'logout') {
                    context.read<AuthProvider>().logout();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'change',
                    child: Row(
                      children: [
                        Icon(Icons.swap_horiz_rounded),
                        SizedBox(width: 8),
                        Text('Cambiar cooperativa'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'add',
                    child: Row(
                      children: [
                        Icon(Icons.add_business_rounded),
                        SizedBox(width: 8),
                        Text('Agregar nueva cooperativa'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_rounded),
                        SizedBox(width: 8),
                        Text('Editar cooperativa actual'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_rounded, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Eliminar cooperativa actual', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout_rounded),
                        SizedBox(width: 8),
                        Text('Cerrar sesión'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'RUTAS', icon: Icon(Icons.route_outlined)),
                Tab(text: 'BUSES', icon: Icon(Icons.directions_bus_outlined)),
                Tab(text: 'CHOFERES', icon: Icon(Icons.people_alt_outlined)),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildRoutesTab(dataProvider, activeCooperative),
              _buildBusesTab(dataProvider, activeCooperative),
              _buildDriversTab(dataProvider, activeCooperative),
            ],
          ),
          floatingActionButton: _buildFAB(activeCooperative),
        );
      },
    );
  }

  Widget _buildRoutesTab(DataProvider dataProvider, Cooperative cooperative) {
    final routes = dataProvider.getRoutesByCooperative(cooperative.id);

    if (routes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.route_outlined, size: 64, color: Colors.green.shade300),
            ),
            const SizedBox(height: 24),
            Text('No hay rutas registradas', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
            const SizedBox(height: 8),
            Text('Comienza agregando una nueva ruta', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: routes.length,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemBuilder: (context, index) {
        final route = routes[index];
        final unitCount = dataProvider.getUnitCountForRoute(route.id);

        return RouteCard(
          route: route,
          unitCount: unitCount,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => RouteDetailScreen(route: route)),
            );
          },
          onEdit: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => RouteFormScreen(
                  cooperativeId: cooperative.id,
                  route: route,
                ),
              ),
            );
          },
          onDelete: () => _showDeleteRouteDialog(context, route.id, route.name),
        );
      },
    );
  }

  Widget _buildBusesTab(DataProvider dataProvider, Cooperative cooperative) {
    final units = dataProvider.getUnitsByCooperative(cooperative.id);

    if (units.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.directions_bus_outlined, size: 64, color: Colors.orange.shade300),
            ),
            const SizedBox(height: 24),
            Text('No hay buses registrados', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
            const SizedBox(height: 8),
            Text('Registra un bus y asígnale un chofer', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: units.length,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemBuilder: (context, index) {
        final unit = units[index];

        final matchingDrivers = dataProvider.drivers.where((d) => d.id == unit.driverId);
        final driverName = matchingDrivers.isNotEmpty ? matchingDrivers.first.name : null;

        return TransportUnitCard(
          unit: unit,
          driverName: driverName,
          onEdit: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TransportUnitFormScreen(
                  cooperativeId: cooperative.id,
                  unit: unit,
                ),
              ),
            );
          },
          onDelete: () => _showDeleteUnitDialog(context, unit.id, unit.unitNumber),
          onTap: () => _showDriverSelectionDialog(context, dataProvider, unit, cooperative.id),
        );
      },
    );
  }

  Widget _buildDriversTab(DataProvider dataProvider, Cooperative cooperative) {
    final drivers = dataProvider.getDriversByCooperative(cooperative.id);

    if (drivers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.people_outline_rounded, size: 64, color: Colors.blue.shade300),
            ),
            const SizedBox(height: 24),
            Text('No hay choferes registrados', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
            const SizedBox(height: 8),
            Text('Registra los choferes de la cooperativa aquí', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: drivers.length,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemBuilder: (context, index) {
        final driver = drivers[index];

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              radius: 24,
              child: Icon(Icons.person, color: Colors.blue.shade800, size: 28),
            ),
            title: Text(
              driver.name,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.phone, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(driver.phone, style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DriverFormScreen(
                        cooperativeId: cooperative.id,
                        driver: driver,
                      ),
                    ),
                  );
                } else if (value == 'delete') {
                  _showDeleteDriverDialog(context, driver.id, driver.name);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget? _buildFAB(Cooperative cooperative) {
    if (_activeTabIndex == 0) {
      return FloatingActionButton.extended(
        key: const ValueKey('fab_route'),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RouteFormScreen(cooperativeId: cooperative.id),
            ),
          );
        },
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Ruta'),
      );
    } else if (_activeTabIndex == 1) {
      return FloatingActionButton.extended(
        key: const ValueKey('fab_bus'),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TransportUnitFormScreen(cooperativeId: cooperative.id),
            ),
          );
        },
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.directions_bus),
        label: const Text('Nuevo Bus'),
      );
    } else if (_activeTabIndex == 2) {
      return FloatingActionButton.extended(
        key: const ValueKey('fab_driver'),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DriverFormScreen(cooperativeId: cooperative.id),
            ),
          );
        },
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Nuevo Chofer'),
      );
    }
    return null;
  }
}
