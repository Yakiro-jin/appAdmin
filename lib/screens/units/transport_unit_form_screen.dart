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
      appBar: AppBar(
        title: Text(
          isEditing ? 'Editar Unidad' : 'Nueva Unidad',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información de la Unidad',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _unitNumberController,
                        decoration: InputDecoration(
                          labelText: 'Número de Unidad',
                          prefixIcon: const Icon(Icons.numbers),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor ingrese el número de unidad';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _plateController,
                        decoration: InputDecoration(
                          labelText: 'Placa',
                          prefixIcon: const Icon(Icons.badge),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        textCapitalization: TextCapitalization.characters,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor ingrese la placa';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _capacityController,
                        decoration: InputDecoration(
                          labelText: 'Capacidad (pasajeros)',
                          prefixIcon: const Icon(Icons.people),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor ingrese la capacidad';
                          }
                          final capacity = int.tryParse(value);
                          if (capacity == null || capacity <= 0) {
                            return 'Ingrese un número válido mayor a 0';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _driverController,
                        decoration: InputDecoration(
                          labelText: 'Conductor (opcional)',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        isEditing ? 'Actualizar' : 'Crear Unidad',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
