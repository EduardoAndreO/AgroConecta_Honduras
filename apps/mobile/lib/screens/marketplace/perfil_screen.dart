// ============================================================
// Perfil Screen — info del usuario + logout
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/marketplace_service.dart';
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

  @override
  void initState() {
    super.initState();
    _cargar();
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
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargar,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(children: [
                  // Avatar + nombre
                  Container(
                    width: 88, height: 88,
                    decoration: BoxDecoration(
                      gradient: AppGradients.brand,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.3),
                          blurRadius: 20, offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.person, color: Colors.white, size: 44),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _user?.nombre ?? 'Usuario',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  StatusChip(
                    label: (_user?.rol ?? auth.rol ?? '—').toUpperCase(),
                    type: StatusType.accent,
                  ),
                  const SizedBox(height: 28),
                  // Datos en cards
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(children: [
                      _dataRow(Icons.email_outlined, 'Email', _user?.email ?? '—'),
                      const Divider(height: 24),
                      _dataRow(Icons.badge_outlined, 'RTN', _user?.rtn ?? '—'),
                      const Divider(height: 24),
                      _dataRow(Icons.phone_outlined, 'Teléfono', _user?.telefono ?? '—'),
                      const Divider(height: 24),
                      _dataRow(Icons.location_on_outlined, 'Departamento', _user?.departamento ?? '—'),
                      const Divider(height: 24),
                      _dataRow(Icons.calendar_today_outlined, 'Miembro desde',
                        _user?.creado.toLocal().toString().substring(0, 10) ?? '—'),
                    ]),
                  ),
                  const SizedBox(height: 24),
                  // Acciones
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Acciones',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      ListTile(
                        leading: const Icon(Icons.edit_outlined, color: AppColors.accent),
                        title: const Text('Editar perfil'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _snack('Próximamente — Tarea 5'),
                        contentPadding: EdgeInsets.zero,
                      ),
                      ListTile(
                        leading: const Icon(Icons.lock_outline, color: AppColors.accent),
                        title: const Text('Cambiar contraseña'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _snack('Próximamente — Tarea 5'),
                        contentPadding: EdgeInsets.zero,
                      ),
                      ListTile(
                        leading: const Icon(Icons.help_outline, color: AppColors.accent),
                        title: const Text('Ayuda y soporte'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _snack('Próximamente — Tarea 5'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ]),
                  ),
                  const SizedBox(height: 24),
                  // Logout
                  OutlinedButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('¿Cerrar sesión?'),
                          content: const Text('Tendrás que volver a iniciar sesión para acceder.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                              child: const Text('Cerrar sesión'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await auth.logout();
                      }
                    },
                    icon: const Icon(Icons.logout, color: AppColors.danger),
                    label: const Text('Cerrar sesión', style: TextStyle(color: AppColors.danger)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'AgroConecta Honduras v0.2.0 · MVP',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                ]),
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
        child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      ),
      Expanded(
        flex: 3,
        child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          textAlign: TextAlign.right, overflow: TextOverflow.ellipsis),
      ),
    ]);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }
}
