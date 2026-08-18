// ============================================================
// Marketplace Screen — feed principal + drawer estilo SV
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/marketplace_service.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import 'publicacion_card.dart';
import 'pedidos_screen.dart';
import 'mis_publicaciones_screen.dart';
import 'notificaciones_screen.dart';
import 'perfil_screen.dart';
import 'crear_publicacion_screen.dart';
import 'dashboard_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  late final MarketplaceService _mk;
  List<Publicacion> _pubs = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _mk = MarketplaceService(context.read<ApiService>());
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _pubs = await _mk.listar();
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              gradient: AppGradients.brand,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.eco, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          const Text('Marketplace'),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _cargar, tooltip: 'Recargar'),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const NotificacionesScreen())),
            tooltip: 'Notificaciones',
          ),
        ],
      ),
      drawer: _buildDrawer(auth),
      body: RefreshIndicator(
        onRefresh: _cargar,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CrearPublicacionScreen()));
          _cargar();
        },
        icon: const Icon(Icons.add),
        label: const Text('Publicar saco'),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildDrawer(AuthService auth) {
    return Drawer(
      child: Container(
        color: AppColors.bgLight,
        child: ListView(padding: EdgeInsets.zero, children: [
          // Header con gradiente
          Container(
            decoration: const BoxDecoration(gradient: AppGradients.brand),
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.eco, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                'AgroConecta',
                style: TextStyle(
                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Honduras',
                style: TextStyle(
                  color: AppColors.accentSoft, fontSize: 12,
                  fontWeight: FontWeight.w500, letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Rol: ${auth.rol ?? '—'}',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ]),
          ),
          // Items
          _drawerItem(Icons.storefront_outlined, 'Marketplace', () {
            Navigator.pop(context);
            _cargar();
          }),
          _drawerItem(Icons.inventory_2_outlined, 'Mis publicaciones', () {
            Navigator.pop(context);
            Navigator.push(context,
              MaterialPageRoute(builder: (_) => const MisPublicacionesScreen()));
          }),
          _drawerItem(Icons.shopping_bag_outlined, 'Mis pedidos', () {
            Navigator.pop(context);
            Navigator.push(context,
              MaterialPageRoute(builder: (_) => const PedidosScreen()));
          }),
          _drawerItem(Icons.notifications_outlined, 'Notificaciones', () {
            Navigator.pop(context);
            Navigator.push(context,
              MaterialPageRoute(builder: (_) => const NotificacionesScreen()));
          }),
          _drawerItem(Icons.dashboard_outlined, 'Dashboard', () {
            Navigator.pop(context);
            Navigator.push(context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()));
          }),
          _drawerItem(Icons.person_outline, 'Perfil', () {
            Navigator.pop(context);
            Navigator.push(context,
              MaterialPageRoute(builder: (_) => const PerfilScreen()));
          }),
          const Divider(),
          _drawerItem(Icons.logout, 'Cerrar sesión', () async {
            Navigator.pop(context);
            await auth.logout();
          }, color: AppColors.danger),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'v0.2.0 · MVP',
              style: TextStyle(
                color: AppColors.textMuted, fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ]),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textPrimary, size: 22),
      title: Text(label, style: TextStyle(
        color: color ?? AppColors.textPrimary, fontWeight: FontWeight.w500,
      )),
      trailing: Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
      onTap: onTap,
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('Cargando publicaciones...',
            style: const TextStyle(color: AppColors.textSecondary)),
        ]),
      );
    }
    if (_error != null) {
      return ListView(
        // Permite pull-to-refresh incluso en estado de error
        children: [
          const SizedBox(height: 80),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.dangerSoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.cloud_off, color: AppColors.danger, size: 40),
                ),
                const SizedBox(height: 16),
                const Text('No se pudo conectar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(_error!,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _cargar,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Reintentar'),
                ),
              ]),
            ),
          ),
        ],
      );
    }
    if (_pubs.isEmpty) {
      return ListView(
        // Permite pull-to-refresh incluso cuando está vacío
        children: [
          const SizedBox(height: 80),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.coffee_outlined, color: AppColors.accent, size: 48),
                ),
                const SizedBox(height: 16),
                const Text('Sin publicaciones activas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const Text('Sé el primero en publicar sacos de café',
                  style: TextStyle(color: AppColors.textSecondary),
                  textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CrearPublicacionScreen()));
                    _cargar();
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Publicar saco'),
                ),
              ]),
            ),
          ),
        ],
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: _pubs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) => PublicacionCard(pub: _pubs[i], mk: _mk, onCompra: _cargar),
    );
  }
}
