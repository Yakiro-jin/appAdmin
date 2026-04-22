import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/transport_unit.dart';
import '../../providers/data_provider.dart';

class TransportUnitFormScreen extends StatefulWidget {
  final String routeId;
  final TransportUnit? unit;

  const TransportUnitFormScreen({
    super.key,
    required this.routeId,
    this.unit,
  });

  @override
  State<TransportUnitFormScreen> createState() =>
      _TransportUnitFormScreenState();
}

class _TransportUnitFormScreenState extends State<TransportUnitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _unitNumberController;
  late TextEditingController _plateController;
  late TextEditingController _capacityController;
  late TextEditingController _driverController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _unitNumberController =
        TextEditingController(text: widget.unit?.unitNumber ?? '');
    _plateController = TextEditingController(text: widget.unit?.plate ?? '');
    _capacityController =
        TextEditingController(text: widget.unit?.capacity.toString() ?? '');
    _driverController = TextEditingController(text: widget.unit?.driver ?? '');
  }

  @override
  void dispose() {
    _unitNumberController.dispose();
    _plateController.dispose();
    _capacityController.dispose();
    _driverController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final dataProvider = context.read<DataProvider>();
    final capacity = int.parse(_capacityController.text.trim());

    if (widget.unit == null) {
      // Create new
      await dataProvider.addTransportUnit(
        _unitNumberController.text.trim(),
        _plateController.text.trim(),
        capacity,
        _driverController.text.trim(),
        widget.routeId,
      );
    } else {
      // Update existing
      await dataProvider.updateTransportUnit(
        widget.unit!.id,
        _unitNumberController.text.trim(),
        _plateController.text.trim(),
        capacity,
        _driverController.text.trim(),
      );
    }

    if (!mounted) return;

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.unit == null
            ? 'Unidad creada exitosamente'
            : 'Unidad actualizada exitosamente'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.unit != null;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Editar Unidad' : 'Nueva Unidad',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(color: Colors.orange.shade700, height: 10),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionTitle('Detalles del Vehículo', Icons.directions_bus),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _unitNumberController,
                              label: 'Número de Unidad',
                              icon: Icons.numbers,
                              validator: (v) => v?.isEmpty ?? true ? 'Campo requerido' : null,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _plateController,
                              label: 'Placa',
                              icon: Icons.badge,
                              capitalization: TextCapitalization.characters,
                              validator: (v) => v?.isEmpty ?? true ? 'Campo requerido' : null,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _capacityController,
                              label: 'Capacidad (pasajeros)',
                              icon: Icons.people,
                              keyboardType: TextInputType.number,
                              formatters: [FilteringTextInputFormatter.digitsOnly],
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Campo requerido';
                                final n = int.tryParse(v);
                                if (n == null || n <= 0) return 'Ingrese un número válido';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Asignación', Icons.person_outline),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildTextField(
                          controller: _driverController,
                          label: 'Conductor asignado',
                          icon: Icons.person,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(
                              isEditing ? 'Actualizar Unidad' : 'Crear Unidad',
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.orange.shade700, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? formatters,
    TextCapitalization capitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      textCapitalization: capitalization,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 22, color: Colors.orange.shade700),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.orange.shade700, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
