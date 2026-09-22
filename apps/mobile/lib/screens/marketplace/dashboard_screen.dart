// ============================================================
// Dashboard Screen — Stitch Premium v4.0
// AppBackground + GlassCard + KPIs con glow + GoogleFonts
// ============================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        backgroundColor: AppColors.bg0,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Dashboard',
            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
          ),
        ),
        body: const AppBackground(
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.accent,
              backgroundColor: AppColors.bg3,
            ),
          ),
        ),
      );
    }
    final activas = _pubs.where((p) => p.estado == 'activa').length;
    final pedidosActivos = _peds
        .where((p) => !['entregado', 'cancelado'].contains(p.estado))
        .length;
    final entregados = _peds.where((p) => p.estado == 'entregado').length;
    final ingresos = _peds
        .where((p) => p.estado == 'entregado')
        .fold(0.0, (acc, p) => acc + p.totalHnl);
    final totalSacos = _peds.fold<int>(0, (sum, p) => sum + p.cantidad);
    final tasaEntrega = _peds.isEmpty ? 0.0 : entregados / _peds.length;

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
          'Panel de Control',
          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _cargar,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: AppBackground(
        child: SafeArea(
          child: RefreshIndicator(
            color: AppColors.accent,
            backgroundColor: AppColors.bg3,
            onRefresh: _cargar,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // Header con Gradiente Premium y Glow
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: AppGradients.brandDiagonal,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                        ),
                        child: const Icon(Icons.analytics_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Resumen de Actividad',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Métricas comerciales en tiempo real',
                              style: GoogleFonts.inter(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Resumen rápido en GlassCard
                GlassCard(
                  padding: const EdgeInsets.all(18),
                  radius: BorderRadius.circular(20),
                  child: Row(children: [
                    Expanded(
                      child: _summaryMetric(
                        'Sacos gestionados',
                        '$totalSacos',
                        Icons.coffee_rounded,
                        AppColors.accentBright,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _summaryMetric(
                        'Tasa de entrega',
                        '${(tasaEntrega * 100).round()}%',
                        Icons.verified_rounded,
                        AppColors.green,
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 18),

                // KPIs en grid 2x2
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.15,
                  children: [
                    _kpiCard(
                      'Publicaciones activas',
                      activas.toString(),
                      Icons.inventory_2_rounded,
                      AppColors.accentBright,
                    ),
                    _kpiCard(
                      'Pedidos en proceso',
                      pedidosActivos.toString(),
                      Icons.local_shipping_rounded,
                      AppColors.warning,
                    ),
                    _kpiCard(
                      'Pedidos entregados',
                      entregados.toString(),
                      Icons.check_circle_rounded,
                      AppColors.green,
                    ),
                    _kpiCard(
                      'Ingresos logrados',
                      'L ${ingresos.toStringAsFixed(0)}',
                      Icons.monetization_on_rounded,
                      AppColors.accent,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Sección Rendimiento
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rendimiento Operativo',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.bg2,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: Text(
                        '${_peds.length} pedidos totales',
                        style: GoogleFonts.inter(
                          color: AppColors.accentSoft,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                GlassCard(
                  padding: const EdgeInsets.all(18),
                  radius: BorderRadius.circular(20),
                  child: Column(children: [
                    _progressRow('Pedidos entregados con éxito', entregados, _peds.length, AppColors.green),
                    const SizedBox(height: 16),
                    _progressRow('En preparación / ruta', pedidosActivos, _peds.length, AppColors.warning),
                    const SizedBox(height: 16),
                    _progressRow('Publicaciones activas en marketplace', activas, _pubs.length, AppColors.accentBright),
                  ]),
                ),
                const SizedBox(height: 24),

                // Acciones Rápidas
                Text(
                  'Acciones Rápidas',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),

                GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  radius: BorderRadius.circular(20),
                  child: Column(children: [
                    _actionRow(Icons.storefront_rounded, 'Explorar Marketplace', () {
                      Navigator.popUntil(context, (r) => r.isFirst);
                    }),
                    Divider(height: 1, color: Colors.white.withValues(alpha: 0.07)),
                    _actionRow(Icons.inventory_2_outlined, 'Gestionar Mis Publicaciones', () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MisPublicacionesScreen()),
                      );
                    }),
                    Divider(height: 1, color: Colors.white.withValues(alpha: 0.07)),
                    _actionRow(Icons.receipt_long_rounded, 'Historial de Mis Pedidos', () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PedidosScreen()),
                      );
                    }),
                  ]),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      radius: BorderRadius.circular(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Icon(Icons.trending_up_rounded, color: color.withValues(alpha: 0.6), size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryMetric(
      String label, String value, IconData icon, Color color) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ]),
      ),
    ]);
  }

  Widget _progressRow(String label, int value, int total, Color color) {
    final progress = total == 0 ? 0.0 : (value / total).clamp(0.0, 1.0);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: Colors.white,
          ),
        ),
        Text(
          '$value de $total',
          style: GoogleFonts.inter(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ]),
      const SizedBox(height: 8),
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: 8,
          backgroundColor: AppColors.bg2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    ]);
  }

  Widget _actionRow(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.accent, size: 20),
      ),
      title: Text(
        label,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
      contentPadding: const EdgeInsets.symmetric(vertical: 2),
      onTap: onTap,
    );
  }
}
