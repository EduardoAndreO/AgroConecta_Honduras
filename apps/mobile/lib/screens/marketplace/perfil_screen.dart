// ============================================================
// Perfil Screen — Stitch Premium v4.0
// AppBackground + GlassCard + Avatar con Glow + GoogleFonts
// ============================================================
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/marketplace_service.dart';
import '../../services/app_settings.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  UserProfile? _user;
  bool _loading = true;
  String? _photoPath;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _photoPath = context.read<AppSettings>().prefs.getString('profile_photo');
    _cargar();
  }

  Future<void> _pickPhoto() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 800,
    );
    if (image == null || !mounted) return;
    setState(() => _photoPath = image.path);
    await context
        .read<AppSettings>()
        .prefs
        .setString('profile_photo', image.path);
  }

  Future<void> _editProfile() async {
    if (_user == null) return;
    final name = TextEditingController(text: _user!.nombre);
    final phone = TextEditingController(text: _user!.telefono);
    var department = _user!.departamento;
    const departments = [
      'Lempira',
      'Intibucá',
      'Santa Bárbara',
      'Comayagua',
      'Copán',
      'La Paz',
      'Francisco Morazán',
      'Cortés',
      'Olancho'
    ];
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          backgroundColor: AppColors.bg2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
          ),
          title: Text(
            'Editar perfil',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                controller: name,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(labelText: 'Nombre completo'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phone,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: departments.contains(department)
                    ? department
                    : departments.first,
                dropdownColor: AppColors.bg2,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(labelText: 'Departamento'),
                items: departments
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(item, style: GoogleFonts.inter(color: Colors.white)),
                        ))
                    .toList(),
                onChanged: (value) =>
                    setDialogState(() => department = value ?? department),
              ),
            ]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'Cancelar',
                style: GoogleFonts.inter(color: AppColors.textMuted),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                'Guardar',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
    final updatedName = name.text.trim();
    final updatedPhone = phone.text.trim();
    name.dispose();
    phone.dispose();
    if (result != true || !mounted) return;
    setState(() => _saving = true);
    try {
      _user = await UserService(context.read<ApiService>()).update(
        nombre: updatedName,
        telefono: updatedPhone,
        departamento: department,
      );
      _snack('Perfil actualizado');
    } catch (error) {
      _snack('No se pudo actualizar: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    try {
      final svc = UserService(context.read<ApiService>());
      _user = await svc.me();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final settings = context.watch<AppSettings>();
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
          'Perfil de Usuario',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: AppBackground(
        child: SafeArea(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.accent,
                    backgroundColor: AppColors.bg3,
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.accent,
                  backgroundColor: AppColors.bg3,
                  onRefresh: _cargar,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(children: [
                      // Avatar + nombre con glow
                      GestureDetector(
                        onTap: _pickPhoto,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 104,
                              height: 104,
                              decoration: BoxDecoration(
                                gradient: AppGradients.brandDiagonal,
                                shape: BoxShape.circle,
                                image: _photoPath != null
                                    ? DecorationImage(
                                        image: FileImage(File(_photoPath!)),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accent.withValues(alpha: 0.35),
                                    blurRadius: 28,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: _photoPath == null
                                  ? const Icon(
                                      Icons.person_rounded,
                                      color: Colors.white,
                                      size: 50,
                                    )
                                  : null,
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.bg0, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt_rounded, color: Colors.black, size: 16),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _user?.nombre ?? 'Usuario Caficultor',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      StatusChip(
                        label: (_user?.rol ?? auth.rol ?? 'Productor').toUpperCase(),
                        type: StatusType.accent,
                      ),
                      const SizedBox(height: 24),

                      // Datos en GlassCard
                      GlassCard(
                        padding: const EdgeInsets.all(20),
                        radius: BorderRadius.circular(20),
                        child: Column(children: [
                          _dataRow(Icons.email_outlined, 'Email', _user?.email ?? '—'),
                          Divider(height: 24, color: Colors.white.withValues(alpha: 0.08)),
                          _dataRow(Icons.badge_outlined, 'RTN', _user?.rtn ?? '—'),
                          Divider(height: 24, color: Colors.white.withValues(alpha: 0.08)),
                          _dataRow(Icons.phone_outlined, 'Teléfono', _user?.telefono ?? '—'),
                          Divider(height: 24, color: Colors.white.withValues(alpha: 0.08)),
                          _dataRow(Icons.location_on_outlined, 'Departamento', _user?.departamento ?? '—'),
                          Divider(height: 24, color: Colors.white.withValues(alpha: 0.08)),
                          _dataRow(
                            Icons.calendar_today_outlined,
                            'Miembro desde',
                            _user?.creado.toLocal().toString().substring(0, 10) ?? '—',
                          ),
                        ]),
                      ),
                      const SizedBox(height: 20),

                      // Acciones
                      GlassCard(
                        padding: const EdgeInsets.all(20),
                        radius: BorderRadius.circular(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Acciones de Cuenta',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.edit_outlined, color: AppColors.accent, size: 20),
                              ),
                              title: Text(
                                'Editar perfil',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                              onTap: _saving ? null : _editProfile,
                              contentPadding: EdgeInsets.zero,
                            ),
                            Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
                            ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.lock_outline_rounded, color: AppColors.accent, size: 20),
                              ),
                              title: Text(
                                'Seguridad y contraseña',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                              onTap: () => _snack('La contraseña se gestiona desde el canal de acceso seguro.'),
                              contentPadding: EdgeInsets.zero,
                            ),
                            Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
                            ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.support_agent_rounded, color: AppColors.accent, size: 20),
                              ),
                              title: Text(
                                'Ayuda y soporte técnico',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                              onTap: () => _snack('Escríbenos directamente al soporte oficial de AgroConecta.'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Card de apariencia
                      GlassCard(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        radius: BorderRadius.circular(18),
                        child: SwitchListTile.adaptive(
                          value: settings.darkMode,
                          onChanged: settings.setDarkMode,
                          activeThumbColor: AppColors.accent,
                          secondary: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              settings.darkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                              color: AppColors.accent,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            'Modo Oscuro Premium',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            'Paleta profunda con acentos cyan y esmeralda',
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Botón Logout estilizado
                      OutlinedButton.icon(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: AppColors.bg2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                              ),
                              title: Text(
                                '¿Cerrar sesión?',
                                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700),
                              ),
                              content: Text(
                                'Tendrás que ingresar tus credenciales para volver a operar.',
                                style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text('Cancelar', style: GoogleFonts.inter(color: AppColors.textMuted)),
                                ),
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.danger,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: Text('Cerrar sesión', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await auth.logout();
                          }
                        },
                        icon: const Icon(Icons.logout_rounded, color: AppColors.danger, size: 18),
                        label: Text(
                          'Cerrar sesión',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.danger,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          side: BorderSide(color: AppColors.danger.withValues(alpha: 0.5)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'AgroConecta Honduras v4.0 · Stitch Premium Edition',
                        style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11),
                      ),
                      const SizedBox(height: 16),
                    ]),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _dataRow(IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, color: AppColors.textSecondary, size: 18),
      const SizedBox(width: 12),
      Expanded(
        flex: 2,
        child: Text(
          label,
          style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
        ),
      ),
      Expanded(
        flex: 3,
        child: Text(
          value,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          textAlign: TextAlign.right,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ]);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.inter(color: Colors.white)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.bg3,
      ),
    );
  }
}
