// ============================================================
// Crear Publicación Screen — formulario para publicar sacos
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../services/marketplace_service.dart';
import '../../theme/app_theme.dart';

class CrearPublicacionScreen extends StatefulWidget {
  const CrearPublicacionScreen({super.key});

  @override
  State<CrearPublicacionScreen> createState() => _CrearPublicacionScreenState();
}

class _CrearPublicacionScreenState extends State<CrearPublicacionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _sacosCtrl = TextEditingController();
  // Cosecha semilla por defecto para pruebas (debe existir en la BD)
  String _cosechaId = '00000000-0000-0000-0000-000000000000';
  bool _loading = false;

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descCtrl.dispose();
    _precioCtrl.dispose();
    _sacosCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final mk = MarketplaceService(context.read<ApiService>());
    try {
      await mk.crear(
        cosechaId: _cosechaId,
        titulo: _tituloCtrl.text.trim(),
        descripcion: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        precioHnl: double.parse(_precioCtrl.text.trim()),
        sacos: int.parse(_sacosCtrl.text.trim()),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Publicación creada exitosamente'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Publicar saco de café')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.accent, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Para publicar necesitas una cosecha registrada. Por ahora usa el ID de cosecha por defecto para probar.',
                          style: const TextStyle(color: AppColors.accentDim, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _tituloCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Título de la publicación',
                    prefixIcon: Icon(Icons.title),
                    hintText: 'Ej: Café Lempira estricto, sacos 60kg',
                  ),
                  validator: (v) => (v == null || v.length < 5) ? 'Mínimo 5 caracteres' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (opcional)',
                    prefixIcon: Icon(Icons.description_outlined),
                    hintText: 'Detalles del café: variedad, beneficiado, altura…',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _precioCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Precio por saco (HNL)',
                    prefixIcon: Icon(Icons.monetization_on_outlined),
                    hintText: 'Ej: 1500.00',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final d = double.tryParse(v ?? '');
                    if (d == null || d <= 0) return 'Precio inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _sacosCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Cantidad de sacos disponibles',
                    prefixIcon: Icon(Icons.inventory_2_outlined),
                    hintText: 'Ej: 20',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final i = int.tryParse(v ?? '');
                    if (i == null || i <= 0) return 'Cantidad inválida';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                if (_loading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.publish_outlined, size: 18),
                    label: const Text('Publicar saco de café'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
