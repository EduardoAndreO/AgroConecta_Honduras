// ============================================================
// Pedidos Screen — lista con confirmar/cancelar/pagar
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/marketplace_service.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';

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
      case 'pendiente':   return StatusType.warning;
      case 'confirmado':  return StatusType.info;
      case 'pagando':     return StatusType.accent;
      case 'pagado':      return StatusType.accent;
      case 'preparando':  return StatusType.info;
      case 'en_ruta':     return StatusType.info;
      case 'entregado':   return StatusType.success;
      case 'cancelado':   return StatusType.danger;
      default:            return StatusType.neutral;
    }
  }

  List<Pedido> get _filtrados {
    if (_filtro == 'todos') return _peds;
    if (_filtro == 'activos') {
      return _peds.where((p) =>
        !['entregado', 'cancelado'].contains(p.estado)).toList();
    }
    return _peds.where((p) => p.estado == _filtro).toList();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    return Scaffold(
      appBar: AppBar(title: const Text('Mis pedidos')),
      body: Column(children: [
        // Filtros
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            _filtroChip('todos', 'Todos'),
            const SizedBox(width: 8),
            _filtroChip('activos', 'Activos'),
            const SizedBox(width: 8),
            _filtroChip('entregado', 'Entregados'),
          ]),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _cargar,
            child: _buildPedidosBody(auth),
          ),
        ),
      ]),
    );
  }

  Widget _buildPedidosBody(AuthService auth) {
    if (_loading) {
      return ListView(
        children: [
          const SizedBox(height: 200),
          const Center(child: CircularProgressIndicator()),
        ],
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
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.cloud_off, color: AppColors.danger, size: 40),
                  ),
                  const SizedBox(height: 16),
                  const Text('Error al cargar',
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
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.shopping_bag_outlined,
                      color: AppColors.accent, size: 48),
                  ),
                  const SizedBox(height: 16),
                  const Text('No tienes pedidos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  const Text('Compra sacos de café desde el marketplace',
                    style: TextStyle(color: AppColors.textSecondary),
                    textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ],
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: _filtrados.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: activo ? AppColors.accent : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: activo ? AppColors.accent : AppColors.border),
        ),
        child: Text(label, style: TextStyle(
          color: activo ? Colors.white : AppColors.textSecondary,
          fontWeight: FontWeight.w600, fontSize: 12,
        )),
      ),
    );
  }

  Widget _pedidoCard(Pedido p, bool soyVendedor) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.shopping_bag_outlined, color: AppColors.accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                'Pedido #${p.id.substring(0, 8)}',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              Text(
                soyVendedor ? 'Eres el vendedor' : 'Eres el comprador',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ]),
          ),
          StatusChip(label: p.estado, type: _colorEstado(p.estado), small: true),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: _infoChip(Icons.inventory, '${p.cantidad} sacos'),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _infoChip(Icons.monetization_on_outlined,
              'HNL ${p.totalHnl.toStringAsFixed(0)}'),
          ),
        ]),
        const SizedBox(height: 8),
        Text(
          'Creado: ${p.creado.toLocal().toString().substring(0, 16)}',
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
        // Acciones
        if (p.estado == 'pendiente' && soyVendedor) ...[
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await _mk.confirmarPedido(p.id);
                    _cargar();
                  } catch (e) {
                    _snack('Error: $e', AppColors.danger);
                  }
                },
                icon: const Icon(Icons.check, size: 16),
                label: const Text('Confirmar'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(0, 40)),
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
              icon: const Icon(Icons.close, color: AppColors.danger),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.dangerSoft,
              ),
            ),
          ]),
        ],
        if (p.estado == 'confirmado' && !soyVendedor) ...[
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _mostrarPago(p),
                icon: const Icon(Icons.credit_card, size: 16),
                label: const Text('Pagar ahora'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(0, 40)),
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
              icon: const Icon(Icons.close, color: AppColors.danger),
              style: IconButton.styleFrom(backgroundColor: AppColors.dangerSoft),
            ),
          ]),
        ],
        if (p.estado == 'pagado' && _pagosCache[p.id] != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.successSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(children: [
              const Icon(Icons.check_circle, color: AppColors.success, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pagado vía ${_pagosCache[p.id]!.metodo.toUpperCase()} · Ref: ${_pagosCache[p.id]!.referencia}',
                  style: const TextStyle(fontSize: 11, color: AppColors.success),
                ),
              ),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  void _mostrarPago(Pedido p) {
    String metodo = 'bac';
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Método de pago',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Total a pagar: HNL ${p.totalHnl.toStringAsFixed(2)}',
              style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            RadioListTile<String>(
              value: 'bac', groupValue: metodo, onChanged: (v) => setModal(() => metodo = v ?? 'bac'),
              title: const Text('BAC Credomatic (Tarjeta)'),
              subtitle: const Text('Procesamiento inmediato'),
            ),
            RadioListTile<String>(
              value: 'ach', groupValue: metodo, onChanged: (v) => setModal(() => metodo = v ?? 'bac'),
              title: const Text('ACH Honduras'),
              subtitle: const Text('Confirmación 24-48h'),
            ),
            RadioListTile<String>(
              value: 'qr', groupValue: metodo, onChanged: (v) => setModal(() => metodo = v ?? 'bac'),
              title: const Text('Billetera QR'),
              subtitle: const Text('Sandbox'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await _pay.iniciar(pedidoId: p.id, metodo: metodo);
                  if (!mounted) return;
                  _snack('Pago aprobado', AppColors.success);
                  _cargar();
                } catch (e) {
                  if (!mounted) return;
                  _snack('Error: $e', AppColors.danger);
                }
              },
              icon: const Icon(Icons.lock_outline, size: 16),
              label: const Text('Confirmar pago'),
            ),
          ]),
        ),
      ),
    );
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }
}
