import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/transport_unit.dart';
import '../../providers/data_provider.dart';

class TransportUnitFormScreen extends StatefulWidget {
  final String cooperativeId;
  final TransportUnit? unit;

  const TransportUnitFormScreen({
    super.key,
    required this.cooperativeId,
    this.unit,
  });

  @override
  State<TransportUnitFormScreen> createState() =>
      _TransportUnitFormScreenState();
}

class _TransportUnitFormScreenState extends State<TransportUnitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _plateController;
  late TextEditingController _modelController;
  late TextEditingController _colorController;
  late TextEditingController _yearController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _plateController = TextEditingController(text: widget.unit?.plate ?? '');
    _modelController = TextEditingController(text: widget.unit?.model ?? '');
    _colorController = TextEditingController(text: widget.unit?.color ?? '');
    
    String initialYear = '';
    if (widget.unit != null && widget.unit!.yearOfManufacture.isNotEmpty) {
      try {
        final parsed = DateTime.parse(widget.unit!.yearOfManufacture);
        initialYear = parsed.year.toString();
      } catch (_) {
        initialYear = widget.unit!.yearOfManufacture;
      }
    }
    _yearController = TextEditingController(text: initialYear);
  }

  @override
  void dispose() {
    _plateController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final dataProvider = context.read<DataProvider>();
    
    // Format year as ISO date string: YYYY-01-01T00:00:00.000Z
    final yearVal = _yearController.text.trim();
    final isoDateStr = '$yearVal-01-01T00:00:00.000Z';

    if (widget.unit == null) {
      // Create new
      await dataProvider.addTransportUnit(
        plate: _plateController.text.trim(),
        model: _modelController.text.trim(),
        color: _colorController.text.trim(),
        yearOfManufacture: isoDateStr,
        cooperativeId: widget.cooperativeId,
      );
    } else {
      // Update existing
      await dataProvider.updateTransportUnit(
        id: widget.unit!.id,
        model: _modelController.text.trim(),
        color: _colorController.text.trim(),
        yearOfManufacture: isoDateStr,
        cooperativeId: widget.cooperativeId,
        routeId: widget.unit!.routeId,
        driverId: widget.unit!.driverId,
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
                              controller: _plateController,
                              label: 'Placa',
                              icon: Icons.badge,
                              enabled: !isEditing,
                              capitalization: TextCapitalization.characters,
                              validator: (v) => v?.isEmpty ?? true ? 'Campo requerido' : null,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _modelController,
                              label: 'Modelo (Ej: Toyota HiAce)',
                              icon: Icons.directions_car,
                              validator: (v) => v?.isEmpty ?? true ? 'Campo requerido' : null,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _colorController,
                              label: 'Color',
                              icon: Icons.color_lens_outlined,
                              validator: (v) => v?.isEmpty ?? true ? 'Campo requerido' : null,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _yearController,
                              label: 'Año de Fabricación (Ej: 2020)',
                              icon: Icons.calendar_today,
                              keyboardType: TextInputType.number,
                              formatters: [FilteringTextInputFormatter.digitsOnly],
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Campo requerido';
                                final n = int.tryParse(v);
                                if (n == null || n < 1900 || n > DateTime.now().year + 1) {
                                  return 'Ingrese un año válido';
                                }
                                return null;
                              },
                            ),
                          ],
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
    bool enabled = true,
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
      enabled: enabled,
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
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade100,
      ),
    );
  }
}
