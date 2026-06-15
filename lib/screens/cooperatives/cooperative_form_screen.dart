import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/cooperative.dart';
import '../../providers/data_provider.dart';

class CooperativeFormScreen extends StatefulWidget {
  final Cooperative? cooperative;

  const CooperativeFormScreen({super.key, this.cooperative});

  @override
  State<CooperativeFormScreen> createState() => _CooperativeFormScreenState();
}

class _CooperativeFormScreenState extends State<CooperativeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _rifController;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _scheduleController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _rifController =
        TextEditingController(text: widget.cooperative?.id ?? '');
    _nameController =
        TextEditingController(text: widget.cooperative?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.cooperative?.description ?? '');
    _locationController =
        TextEditingController(text: widget.cooperative?.location ?? '');
    _scheduleController =
        TextEditingController(text: widget.cooperative?.schedule ?? '');
  }

  @override
  void dispose() {
    _rifController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _scheduleController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final dataProvider = context.read<DataProvider>();

    if (widget.cooperative == null) {
      // Create new
      await dataProvider.addCooperative(
        id: _rifController.text.trim(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        schedule: _scheduleController.text.trim(),
      );
    } else {
      // Update existing
      await dataProvider.updateCooperative(
        id: widget.cooperative!.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        schedule: _scheduleController.text.trim(),
      );
    }

    if (!mounted) return;

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.cooperative == null
            ? 'Cooperativa creada exitosamente'
            : 'Cooperativa actualizada exitosamente'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.cooperative != null;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Editar Cooperativa' : 'Nueva Cooperativa',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFF1A1F2B),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(color: const Color(0xFF1A1F2B), height: 10),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionTitle('Información de la Empresa', Icons.business_rounded),
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
                              controller: _rifController,
                              label: 'RIF de la Cooperativa',
                              icon: Icons.badge_outlined,
                              enabled: !isEditing,
                              validator: (v) {
                                if (v?.isEmpty ?? true) return 'Campo requerido';
                                if (!RegExp(r'^[JVEG]-\d{8}-\d$').hasMatch(v!.trim())) {
                                  return 'Formato inválido (Ej: J-12345678-9)';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _nameController,
                              label: 'Nombre de la Cooperativa',
                              icon: Icons.business,
                              validator: (v) => v?.isEmpty ?? true ? 'Campo requerido' : null,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _locationController,
                              label: 'Ubicación / Ciudad',
                              icon: Icons.location_on_outlined,
                              validator: (v) => v?.isEmpty ?? true ? 'Campo requerido' : null,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _scheduleController,
                              label: 'Horario (Ej: 05:00-22:00)',
                              icon: Icons.access_time,
                              validator: (v) => v?.isEmpty ?? true ? 'Campo requerido' : null,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _descriptionController,
                              label: 'Descripción o Eslogan',
                              icon: Icons.description_outlined,
                              maxLines: 3,
                              validator: (v) => v?.isEmpty ?? true ? 'Campo requerido' : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1F2B),
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
                              isEditing ? 'Guardar Cambios' : 'Crear Cooperativa',
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
        Icon(icon, color: const Color(0xFF1A1F2B), size: 20),
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
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 22, color: const Color(0xFF1A1F2B)),
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
          borderSide: BorderSide(color: const Color(0xFF1A1F2B), width: 2),
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
