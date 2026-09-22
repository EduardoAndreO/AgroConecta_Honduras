// ============================================================
// PublicacionCard — Premium v4.0 (Stitch)
// GlassCard + GradientButton + animación de expand
// ============================================================
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../services/marketplace_service.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../services/cart_service.dart';
import '../../services/notification_service.dart';

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

class _PublicacionCardState extends State<PublicacionCard>
    with SingleTickerProviderStateMixin {
  bool _comprando = false;
  int _cantidad = 1;
  bool _expandido = false;

  late AnimationController _expandCtrl;
  late Animation<double> _expandAnim;

  static final NumberFormat _fmt =
      NumberFormat.currency(locale: 'es_HN', symbol: 'HNL ', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    _expandCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _expandAnim = CurvedAnimation(parent: _expandCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _expandCtrl.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() => _expandido = !_expandido);
    if (_expandido) {
      _expandCtrl.forward();
    } else {
      _expandCtrl.reverse();
    }
  }

  Future<void> _comprar() async {
    setState(() => _comprando = true);
    try {
      await widget.mk
          .crearPedido(publicacionId: widget.pub.id, cantidad: _cantidad);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✓ Pedido creado · HNL ',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
      await NotificationService.instance.show(
          title: 'Pedido creado',
          body: 'Tu pedido quedó pendiente de confirmación.');
      widget.onCompra();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
      radius: BorderRadius.circular(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Header ─────────────────────────────────────────
        Row(children: [
          GradientIcon(
            icon: Icons.coffee_rounded,
            size: 22,
            containerSize: 48,
            gradient: AppGradients.brandDiagonal,
            borderRadius: BorderRadius.circular(14),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                widget.pub.titulo,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(children: [
                const Icon(Icons.person_outline, size: 13, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.pub.vendedorNombre,
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary, fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ]),
            ]),
          ),
          StatusChip(
            label: widget.pub.estado,
            type: _estadoChip(widget.pub.estado),
            small: true,
          ),
        ]),

        // ── Descripción expandible ──────────────────────────
        SizeTransition(
          sizeFactor: _expandAnim,
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              widget.pub.descripcion ?? '',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary, fontSize: 13, height: 1.5,
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // ── Precio + disponibilidad ────────────────────────
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.12)),
          ),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  _fmt.format(widget.pub.precioHnl),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.accentBright,
                  ),
                ),
                Text(
                  'por saco',
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                ),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.infoSoft,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
              ),
              child: Text(
                ' disp.',
                style: GoogleFonts.inter(
                  color: AppColors.info, fontWeight: FontWeight.w600, fontSize: 13,
                ),
              ),
            ),
          ]),
        ),

        const SizedBox(height: 14),

        // ── Controles de cantidad + acciones ───────────────
        Row(children: [
          // Botón -
          _QtyButton(
            icon: Icons.remove_rounded,
            enabled: _cantidad > 1,
            onTap: () => setState(() => _cantidad--),
          ),
          const SizedBox(width: 8),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.bg3,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
            ),
            child: Center(
              child: Text(
                '',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800, fontSize: 17, color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Botón +
          _QtyButton(
            icon: Icons.add_rounded,
            enabled: _cantidad < widget.pub.sacos,
            onTap: () => setState(() => _cantidad++),
          ),
          const Spacer(),
          if (_comprando)
            const SizedBox(
              width: 26, height: 26,
              child: CircularProgressIndicator(
                strokeWidth: 2.5, color: AppColors.accent,
              ),
            )
          else
            Row(mainAxisSize: MainAxisSize.min, children: [
              // Carrito
              GestureDetector(
                onTap: () {
                  context.read<CartService>().add(widget.pub, quantity: _cantidad);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Agregado al carrito',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                      backgroundColor: AppColors.bg3,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                child: Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(Icons.add_shopping_cart_outlined,
                      color: AppColors.accent, size: 19),
                ),
              ),
              const SizedBox(width: 8),
              // Comprar
              GradientButton(
                onPressed: _comprar,
                gradient: AppGradients.brandGreen,
                height: 42,
                borderRadius: BorderRadius.circular(12),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text('Comprar', style: GoogleFonts.plusJakartaSans(
                      fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white,
                    )),
                  ],
                ),
              ),
            ]),
        ]),

        const SizedBox(height: 10),

        // ── Toggle ver más ─────────────────────────────────
        if (widget.pub.descripcion != null && widget.pub.descripcion!.isNotEmpty)
          Center(
            child: GestureDetector(
              onTap: _toggleExpand,
              child: AnimatedBuilder(
                animation: _expandAnim,
                builder: (ctx, _) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _expandido ? 'Ver menos' : 'Ver más',
                      style: GoogleFonts.inter(
                        color: AppColors.accent, fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 2),
                    AnimatedRotation(
                      turns: _expandido ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 280),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.accent, size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ]),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.accent.withValues(alpha: 0.12)
              : AppColors.bg3.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: enabled
                ? AppColors.accent.withValues(alpha: 0.4)
                : AppColors.border.withValues(alpha: 0.2),
          ),
        ),
        child: Icon(icon,
          color: enabled ? AppColors.accent : AppColors.textMuted,
          size: 20,
        ),
      ),
    );
  }
}
