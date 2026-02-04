import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/cooperative_card.dart';
import 'cooperative_form_screen.dart';
import '../routes/route_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showDeleteDialog(
      BuildContext context, String cooperativeId, String cooperativeName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
            '¿Está seguro de eliminar la cooperativa "$cooperativeName"? Esto también eliminará todas sus rutas y unidades.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<DataProvider>().deleteCooperative(cooperativeId);
              Navigator.of(ctx).pop();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Administrador de Transporte',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
            },
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Consumer<DataProvider>(
        builder: (context, dataProvider, child) {
          final cooperatives = dataProvider.cooperatives;

          return Column(
            children: [
              // Statistics Section
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey.shade50,
                child: Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: Icons.business,
                        title: 'Cooperativas',
                        value: '${cooperatives.length}',
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatCard(
                        icon: Icons.route,
                        title: 'Rutas',
                        value: '${dataProvider.getTotalRoutes()}',
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatCard(
                        icon: Icons.directions_bus,
                        title: 'Unidades',
                        value: '${dataProvider.getTotalUnits()}',
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              // Cooperatives List
              Expanded(
                child: cooperatives.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.business_outlined,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay cooperativas registradas',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Presiona el botón + para agregar una',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: cooperatives.length,
                        itemBuilder: (context, index) {
                          final cooperative = cooperatives[index];
                          final routeCount = dataProvider
                              .getRouteCountForCooperative(cooperative.id);

                          return CooperativeCard(
                            cooperative: cooperative,
                            routeCount: routeCount,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      RouteListScreen(cooperative: cooperative),
                                ),
                              );
                            },
                            onEdit: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => CooperativeFormScreen(
                                      cooperative: cooperative),
                                ),
                              );
                            },
                            onDelete: () {
                              _showDeleteDialog(
                                  context, cooperative.id, cooperative.name);
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CooperativeFormScreen(),
            ),
          );
        },
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Cooperativa'),
      ),
    );
  }
}
