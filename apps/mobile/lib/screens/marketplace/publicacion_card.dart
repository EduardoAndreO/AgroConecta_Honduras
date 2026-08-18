// ============================================================
// Card de Publicación — estilo SV con gradiente y comprar
// ============================================================
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/marketplace_service.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';

class PublicacionCard extends StatefulWidget {
  final Publicacion pub;
  final MarketplaceService mk;
  final VoidCallback onCompra;

  const PublicacionCard({
    super.key,
    required this.pub,
    required this.mk,
    required this.onCompra,
  });

  @override
  State<PublicacionCard> createState() => _PublicacionCardState();
}

class _PublicacionCardState extends State<PublicacionCard> {
  bool _comprando = false;
  int _cantidad = 1;
  bool _expandido = false;
  // Formato HNL compartido entre instancias (micro-optimización)
  static final NumberFormat _fmt = NumberFormat.currency(
    locale: 'es_HN', symbol: 'HNL ', decimalDigits: 2);

  Future<void> _comprar() async {
    setState(() => _comprando = true);
    try {
      final pedido = await widget.mk.crearPedido(
        publicacionId: widget.pub.id, cantidad: _cantidad);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Pedido creado por HNL ${pedido.totalHnl.toStringAsFixed(2)}'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      widget.onCompra();
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
      if (mounted) setState(() => _comprando = false);
    }
  }

  StatusType _estadoChip(String estado) {
    switch (estado) {
      case 'activa': return StatusType.success;
      case 'cerrada': return StatusType.warning;
      case 'cancelada': return StatusType.danger;
      default: return StatusType.neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              gradient: AppGradients.brand,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.coffee, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                widget.pub.titulo,
                style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(children: [
                const Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.pub.vendedorNombre,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                ),
              ]),
            ]),
          ),
          StatusChip(label: widget.pub.estado, type: _estadoChip(widget.pub.estado), small: true),
        ]),
        if (widget.pub.descripcion != null && _expandido) ...[
          const SizedBox(height: 12),
          Text(widget.pub.descripcion!, style: const TextStyle(color: AppColors.textSecondary)),
        ],
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  _fmt.format(widget.pub.precioHnl),
                  style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.accent),
                ),
                const Text('por saco', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.infoSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${widget.pub.sacos} disp.',
                style: const TextStyle(
                  color: AppColors.info, fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 14),
        Row(children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: AppColors.accent),
            onPressed: _cantidad > 1 ? () => setState(() => _cantidad--) : null,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.bgLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('$_cantidad', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.accent),
            onPressed: _cantidad < widget.pub.sacos ? () => setState(() => _cantidad++) : null,
          ),
          const Spacer(),
          if (_comprando)
            const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
          else
            ElevatedButton.icon(
              onPressed: _comprar,
              icon: const Icon(Icons.shopping_bag_outlined, size: 16),
              label: const Text('Comprar'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(130, 44),
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
            ),
        ]),
        const SizedBox(height: 8),
        Center(
          child: GestureDetector(
            onTap: () => setState(() => _expandido = !_expandido),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(
                _expandido ? 'Ver menos' : 'Ver más',
                style: const TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              Icon(
                _expandido ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: AppColors.accent, size: 16,
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
