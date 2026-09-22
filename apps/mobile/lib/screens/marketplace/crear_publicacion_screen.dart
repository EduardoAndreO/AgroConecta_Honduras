// ============================================================
// Crear Publicación Screen — Stitch Premium v4.0
// AppBackground + GlassCard + GradientButton + GoogleFonts
// ============================================================
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  // El backend vincula la publicación con la primera cosecha del productor.
  final String _cosechaId = '00000000-0000-0000-0000-000000000000';
  bool _loading = false;
  XFile? _image;

  Future<void> _pickProductImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (image != null && mounted) setState(() => _image = image);
  }

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
      final publication = await mk.crear(
        cosechaId: _cosechaId,
        titulo: _tituloCtrl.text.trim(),
        descripcion:
            _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        precioHnl: double.parse(_precioCtrl.text.trim()),
        sacos: int.parse(_sacosCtrl.text.trim()),
      );
      if (_image != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'publication_image_${publication.id}', _image!.path);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Publicación creada exitosamente',
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e', style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Publicar Café',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Banner informativo con glow suave
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.tips_and_updates_outlined, color: AppColors.accentBright, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Tu lote estará visible de inmediato para compradores y tostadores de toda Honduras.',
                            style: GoogleFonts.inter(
                              color: AppColors.accentBright,
                              fontSize: 12,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Selector de Imagen
                  InkWell(
                    onTap: _pickProductImage,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: AppColors.bg2,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _image != null ? AppColors.accentBright : Colors.white.withValues(alpha: 0.12),
                          width: 1.5,
                        ),
                        boxShadow: _image != null
                            ? [
                                BoxShadow(
                                  color: AppColors.accent.withValues(alpha: 0.2),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: _image == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add_photo_alternate_rounded,
                                    color: AppColors.accentBright,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Subir foto de la cosecha',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Opcional · JPG o PNG en alta resolución',
                                  style: GoogleFonts.inter(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(19),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.file(File(_image!.path), fit: BoxFit.cover),
                                  Positioned(
                                    bottom: 10,
                                    right: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.7),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Cambiar',
                                            style: GoogleFonts.inter(color: Colors.white, fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Formulario en GlassCard
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    radius: BorderRadius.circular(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detalles de la Cosecha',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _tituloCtrl,
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                          decoration: const InputDecoration(
                            labelText: 'Título del lote',
                            prefixIcon: Icon(Icons.title_rounded),
                            hintText: 'Ej: Café Lempira estricto, sacos 60kg',
                          ),
                          validator: (v) => (v == null || v.length < 5)
                              ? 'Mínimo 5 caracteres'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _descCtrl,
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                          decoration: const InputDecoration(
                            labelText: 'Descripción detallada (opcional)',
                            prefixIcon: Icon(Icons.description_outlined),
                            hintText: 'Variedad, altura msnm, notas de cata…',
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _precioCtrl,
                                style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                                decoration: const InputDecoration(
                                  labelText: 'Precio por saco (HNL)',
                                  prefixIcon: Icon(Icons.monetization_on_outlined),
                                  hintText: '1500.00',
                                ),
                                keyboardType: TextInputType.number,
                                validator: (v) {
                                  final d = double.tryParse(v ?? '');
                                  if (d == null || d <= 0) return 'Precio inválido';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: TextFormField(
                                controller: _sacosCtrl,
                                style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                                decoration: const InputDecoration(
                                  labelText: 'Cantidad de sacos',
                                  prefixIcon: Icon(Icons.inventory_2_outlined),
                                  hintText: '20',
                                ),
                                keyboardType: TextInputType.number,
                                validator: (v) {
                                  final i = int.tryParse(v ?? '');
                                  if (i == null || i <= 0) return 'Cantidad inválida';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (_loading)
                    const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accent,
                        backgroundColor: AppColors.bg3,
                      ),
                    )
                  else
                    GradientButton(
                      gradient: AppGradients.brandDiagonal,
                      onPressed: _submit,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.publish_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Publicar Café en Marketplace',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
