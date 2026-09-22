// ============================================================
// Pedidos Screen — Stitch Premium v4.0
// AppBackground + GlassCard + StatusChip + GoogleFonts
// ============================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/marketplace_service.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../services/notification_service.dart';

class PedidosScreen extends StatefulWidget {
  const PedidosScreen({super.key});

  @override
  State<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  late final MarketplaceService _mk;
  late final PaymentsService _pay;
  final Map<String, Pago?> _pagosCache = {};
  List<Pedido> _peds = [];
  bool _loading = true;
  String? _error;
  String _filtro = 'todos';

  @override
  void initState() {
    super.initState();
    final api = context.read<ApiService>();
    _mk = MarketplaceService(api);
    _pay = PaymentsService(api);
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _peds = await _mk.misPedidos();
      for (final p in _peds) {
        if (p.estado == 'pagado' || p.estado == 'pagando') {
          _pagosCache[p.id] = await _pay.pagoDePedido(p.id);
        }
      }
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  StatusType _colorEstado(String e) {
    switch (e) {
      case 'pendiente':
        return StatusType.warning;
      case 'confirmado':
        return StatusType.info;
      case 'pagando':
        return StatusType.accent;
      case 'pagado':
        return StatusType.accent;
      case 'preparando':
        return StatusType.info;
      case 'en_ruta':
        return StatusType.info;
      case 'entregado':
        return StatusType.success;
      case 'cancelado':
        return StatusType.danger;
      default:
        return StatusType.neutral;
    }
  }

  List<Pedido> get _filtrados {
    if (_filtro == 'todos') return _peds;
    if (_filtro == 'activos') {
      return _peds
          .where((p) => !['entregado', 'cancelado'].contains(p.estado))
          .toList();
    }
    return _peds.where((p) => p.estado == _filtro).toList();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
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
          'Mis Pedidos',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
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
          child: Column(children: [
            // Filtros horizontales
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(children: [
                  _filtroChip('todos', 'Todos los pedidos'),
                  const SizedBox(width: 8),
                  _filtroChip('activos', 'En proceso'),
                  const SizedBox(width: 8),
                  _filtroChip('entregado', 'Entregados'),
                ]),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.accent,
                backgroundColor: AppColors.bg3,
                onRefresh: _cargar,
                child: _buildPedidosBody(auth),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildPedidosBody(AuthService auth) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.accent,
          backgroundColor: AppColors.bg3,
        ),
      );
    }
    if (_error != null) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.dangerSoft,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.cloud_off_rounded, color: AppColors.danger, size: 36),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar pedidos',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.bg2,
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _cargar,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text('Reintentar', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
    if (_filtrados.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
                    ),
                    child: const Icon(Icons.shopping_bag_outlined, color: AppColors.accentBright, size: 44),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes pedidos aquí',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Compra sacos de café directamente desde el marketplace',
                    style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: _filtrados.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (ctx, i) {
        final p = _filtrados[i];
        final soyVendedor = p.vendedorId == auth.userId;
        return _pedidoCard(p, soyVendedor);
      },
    );
  }

  Widget _filtroChip(String valor, String label) {
    final activo = _filtro == valor;
    return GestureDetector(
      onTap: () => setState(() => _filtro = valor),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          gradient: activo ? AppGradients.brandDiagonal : null,
          color: activo ? null : AppColors.bg2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: activo ? AppColors.accentBright : Colors.white.withValues(alpha: 0.1),
            width: 1.2,
          ),
          boxShadow: activo
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: activo ? Colors.white : AppColors.textSecondary,
            fontWeight: activo ? FontWeight.w700 : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _pedidoCard(Pedido p, bool soyVendedor) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      radius: BorderRadius.circular(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _coffeeProductImage(),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pedido #${p.id.length > 8 ? p.id.substring(0, 8) : p.id}',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                    StatusChip(
                      label: p.estado.toUpperCase(),
                      type: _colorEstado(p.estado),
                      small: true,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  soyVendedor ? 'Eres el vendedor' : 'Eres el comprador',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: soyVendedor ? AppColors.greenSoft : AppColors.accentSoft,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: _infoChip(Icons.inventory_2_rounded, '${p.cantidad} sacos'),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _infoChip(Icons.monetization_on_rounded, 'HNL ${p.totalHnl.toStringAsFixed(0)}'),
          ),
        ]),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Fecha: ${p.creado.toLocal().toString().substring(0, 16)}',
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),

        // Acciones
        if (p.estado == 'pendiente' && soyVendedor) ...[
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () async {
                  try {
                    await _mk.confirmarPedido(p.id);
                    await NotificationService.instance.show(
                      title: 'Pedido confirmado',
                      body: 'El comprador recibió la confirmación del pedido.',
                    );
                    _cargar();
                  } catch (e) {
                    _snack('Error: $e', AppColors.danger);
                  }
                },
                icon: const Icon(Icons.check_rounded, size: 16),
                label: Text('Confirmar Pedido', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.greenDim,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(0, 44),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () async {
                try {
                  await _mk.cancelarPedido(p.id);
                  _cargar();
                } catch (e) {
                  _snack('Error: $e', AppColors.danger);
                }
              },
              icon: const Icon(Icons.close_rounded, color: AppColors.danger),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.dangerSoft,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ]),
        ],
        if (p.estado == 'confirmado' && !soyVendedor) ...[
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _mostrarPago(p),
                icon: const Icon(Icons.credit_card_rounded, size: 16),
                label: Text('Pagar Ahora', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(0, 44),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () async {
                try {
                  await _mk.cancelarPedido(p.id);
                  _cargar();
                } catch (e) {
                  _snack('Error: $e', AppColors.danger);
                }
              },
              icon: const Icon(Icons.close_rounded, color: AppColors.danger),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.dangerSoft,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ]),
        ],
        if (p.estado == 'pagado' && _pagosCache[p.id] != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.successSoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.green.withValues(alpha: 0.25)),
            ),
            child: Row(children: [
              const Icon(Icons.verified_rounded, color: AppColors.success, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pagado vía ${_pagosCache[p.id]!.metodo.toUpperCase()} · Ref: ${_pagosCache[p.id]!.referencia}',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.greenSoft, fontWeight: FontWeight.w600),
                ),
              ),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _coffeeProductImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        'https://images.unsplash.com/photo-1447933601403-0c6688de566e?auto=format&fit=crop&w=240&q=80',
        width: 72,
        height: 64,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 72,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.bg2,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: const Icon(Icons.coffee_rounded, color: AppColors.accentBright, size: 28),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 15, color: AppColors.accentSoft),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ]),
    );
  }

  void _mostrarPago(Pedido p) {
    String metodo = 'bac';
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bg1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Método de Pago',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Total a pagar: HNL ${p.totalHnl.toStringAsFixed(2)}',
                style: GoogleFonts.inter(color: AppColors.accentBright, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              RadioGroup<String>(
                groupValue: metodo,
                onChanged: (v) => setModal(() => metodo = v ?? 'bac'),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      value: 'bac',
                      activeColor: AppColors.accent,
                      title: Text('BAC Credomatic (Tarjeta)', style: GoogleFonts.inter(color: Colors.white)),
                      subtitle: Text('Procesamiento inmediato seguro', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
                    ),
                    RadioListTile<String>(
                      value: 'ach',
                      activeColor: AppColors.accent,
                      title: Text('ACH Honduras', style: GoogleFonts.inter(color: Colors.white)),
                      subtitle: Text('Transferencia interbancaria nacional', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
                    ),
                    RadioListTile<String>(
                      value: 'qr',
                      activeColor: AppColors.accent,
                      title: Text('Billetera Digital / QR', style: GoogleFonts.inter(color: Colors.white)),
                      subtitle: Text('Dilo, Tengo o Banrural QR', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GradientButton(
                gradient: AppGradients.brandDiagonal,
                onPressed: () async {
                  Navigator.pop(ctx);
                  try {
                    await _pay.iniciar(pedidoId: p.id, metodo: metodo);
                    await NotificationService.instance.show(
                      title: 'Pago aprobado',
                      body: 'El pago del pedido fue aprobado en sandbox.',
                    );
                    if (!mounted) return;
                    _snack('Pago aprobado', AppColors.success);
                    _cargar();
                  } catch (e) {
                    if (!mounted) return;
                    _snack('Error: $e', AppColors.danger);
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Confirmar Pago Sandbox',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
