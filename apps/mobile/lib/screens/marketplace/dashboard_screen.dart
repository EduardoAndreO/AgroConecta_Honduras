// ============================================================
// Dashboard Screen — métricas rápidas del usuario
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../services/marketplace_service.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import 'mis_publicaciones_screen.dart';
import 'pedidos_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final MarketplaceService _mk;
  List<Publicacion> _pubs = [];
  List<Pedido> _peds = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _mk = MarketplaceService(context.read<ApiService>());
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _mk.misPublicaciones(),
        _mk.misPedidos(),
      ]);
      _pubs = results[0] as List<Publicacion>;
      _peds = results[1] as List<Pedido>;
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dashboard')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final activas = _pubs.where((p) => p.estado == 'activa').length;
    final pedidosActivos = _peds.where((p) =>
      !['entregado', 'cancelado'].contains(p.estado)).length;
    final entregados = _peds.where((p) => p.estado == 'entregado').length;
    final ingresos = _peds
        .where((p) => p.estado == 'entregado')
        .fold(0.0, (acc, p) => acc + p.totalHnl);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: RefreshIndicator(
        onRefresh: _cargar,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header con gradiente
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppGradients.brand,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Resumen de actividad',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Última actualización: ${DateTime.now().toLocal().toString().substring(0, 16)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 11)),
              ]),
            ),
            const SizedBox(height: 16),
            // KPIs en grid 2x2
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0,
              children: [
                _kpiCard('Publicaciones activas', activas.toString(), Icons.inventory_2_outlined, AppColors.accent),
                _kpiCard('Pedidos en proceso', pedidosActivos.toString(), Icons.local_shipping_outlined, AppColors.info),
                _kpiCard('Pedidos entregados', entregados.toString(), Icons.check_circle_outline, AppColors.success),
                _kpiCard('Ingresos (HNL)', ingresos.toStringAsFixed(0), Icons.monetization_on_outlined, AppColors.warning),
              ],
            ),
            const SizedBox(height: 24),
            // Acciones rápidas
            const Text('Acciones rápidas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                _actionRow(Icons.storefront_outlined, 'Ver marketplace', () {
                  Navigator.popUntil(context, (r) => r.isFirst);
                }),
                const Divider(),
                _actionRow(Icons.inventory_2_outlined, 'Mis publicaciones', () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const MisPublicacionesScreen()));
                }),
                const Divider(),
                _actionRow(Icons.shopping_bag_outlined, 'Mis pedidos', () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const PedidosScreen()));
                }),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
        ]),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(
          fontSize: 24, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ]),
    );
  }

  Widget _actionRow(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.accent, size: 22),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }
}
