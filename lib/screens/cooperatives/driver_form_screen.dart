import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/driver.dart';
import '../../providers/data_provider.dart';

class DriverFormScreen extends StatefulWidget {
  final String cooperativeId;
  final Driver? driver;

  const DriverFormScreen({
    super.key,
    required this.cooperativeId,
    this.driver,
  });

  @override
  State<DriverFormScreen> createState() => _DriverFormScreenState();
}

class _DriverFormScreenState extends State<DriverFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.driver?.name ?? '');
    _phoneController = TextEditingController(text: widget.driver?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final dataProvider = context.read<DataProvider>();

    if (widget.driver == null) {
      // Create new
      await dataProvider.addDriver(
        _nameController.text.trim(),
        _phoneController.text.trim(),
        widget.cooperativeId,
      );
    } else {
      // Update existing
      await dataProvider.updateDriver(
        widget.driver!.id,
        _nameController.text.trim(),
        _phoneController.text.trim(),
      );
    }

    if (!mounted) return;

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.driver == null
            ? 'Chofer registrado exitosamente'
            : 'Chofer actualizado exitosamente'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.driver != null;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Editar Chofer' : 'Nuevo Chofer',
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
                    _buildSectionTitle('Información del Chofer', Icons.person_outline),
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
                              controller: _nameController,
                              label: 'Nombre completo',
                              icon: Icons.person,
                              validator: (v) => v?.isEmpty ?? true ? 'Campo requerido' : null,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _phoneController,
                              label: 'Número de teléfono',
                              icon: Icons.phone,
                              keyboardType: TextInputType.phone,
                              formatters: [FilteringTextInputFormatter.digitsOnly],
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
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              isEditing ? 'Guardar Cambios' : 'Registrar Chofer',
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.w600),
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
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? formatters,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: formatters,
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
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
