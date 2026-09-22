// ============================================================
// Marketplace Screen — Premium v4.0 (Stitch)
// AppBackground + glassmorphism cards + GradientButton FAB
// ============================================================
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/app_settings.dart';
import '../../services/cart_service.dart';
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
import 'carrito_screen.dart';
import '../login/login_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen>
    with TickerProviderStateMixin {
  late final MarketplaceService _mk;
  List<Publicacion> _pubs = [];
  bool _loading = true;
  String? _error;

  late AnimationController _fabCtrl;
  late Animation<double> _fabScale;

  @override
  void initState() {
    super.initState();
    _mk = MarketplaceService(context.read<ApiService>());
    _fabCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fabScale = CurvedAnimation(parent: _fabCtrl, curve: Curves.elasticOut);
    _cargar();
  }

  @override
  void dispose() {
    _fabCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() { _loading = true; _error = null; });
    try {
      _pubs = await _mk.listar();
      _fabCtrl.forward(from: 0);
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    return Scaffold(
      backgroundColor: AppColors.bg0,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(auth),
      body: AppBackground(
        child: RefreshIndicator(
          color: AppColors.accent,
          backgroundColor: AppColors.bg3,
          onRefresh: _cargar,
          child: _buildBody(),
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabScale,
        child: _buildFAB(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AppBar(
            backgroundColor: AppColors.bg0.withValues(alpha: 0.88),
            title: Row(children: [
              GradientIcon(
                icon: Icons.eco_rounded,
                size: 18,
                containerSize: 34,
                gradient: AppGradients.brandDiagonal,
                borderRadius: BorderRadius.circular(9),
                shadow: const [],
              ),
              const SizedBox(width: 10),
              Text(
                'Marketplace',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white,
                ),
              ),
            ]),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                onPressed: _cargar,
                tooltip: 'Recargar',
              ),
              Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotificacionesScreen()),
                    ),
                    tooltip: 'Notificaciones',
                  ),
                ],
              ),
              const SizedBox(width: 4),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                height: 1,
                color: AppColors.accent.withValues(alpha: 0.12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.brandGreen,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.fab,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withValues(alpha: 0.15),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CrearPublicacionScreen()),
            );
            _cargar();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Publicar saco',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(AuthService auth) {
    return Drawer(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Material(
            color: AppColors.bg0.withValues(alpha: 0.96),
            child: ListView(padding: EdgeInsets.zero, children: [
              Container(
                decoration: const BoxDecoration(gradient: AppGradients.background),
                padding: const EdgeInsets.fromLTRB(20, 48, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GradientIcon(
                      icon: Icons.eco_rounded,
                      size: 32,
                      containerSize: 60,
                      gradient: AppGradients.brandDiagonal,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'AgroConecta',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'HONDURAS',
                      style: GoogleFonts.inter(
                        color: AppColors.accent, fontSize: 11,
                        fontWeight: FontWeight.w600, letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'Rol: ',
                        style: GoogleFonts.inter(
                          color: AppColors.accentSoft, fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _drawerItem(Icons.storefront_outlined, 'Marketplace', () {
                Navigator.pop(context); _cargar();
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
              Consumer<CartService>(
                builder: (ctx, cart, _) => _drawerItem(
                  Icons.shopping_cart_outlined,
                  'Carrito ()',
                  () {
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const CarritoScreen()));
                  },
                ),
              ),
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
              Consumer<AppSettings>(
                builder: (ctx, settings, _) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: SwitchListTile.adaptive(
                    value: settings.darkMode,
                    onChanged: (val) => settings.setDarkMode(val),
                    activeThumbColor: AppColors.accent,
                    secondary: Icon(
                      settings.darkMode
                          ? Icons.dark_mode_outlined
                          : Icons.light_mode_outlined,
                      color: AppColors.accent,
                    ),
                    title: Text('Modo oscuro',
                        style: GoogleFonts.inter(
                          color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14,
                        )),
                    subtitle: Text('Cambiar apariencia',
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary, fontSize: 12,
                        )),
                  ),
                ),
              ),
              Divider(color: AppColors.border.withValues(alpha: 0.3), height: 8),
              _drawerItem(Icons.logout_rounded, 'Cerrar sesión', () async {
                Navigator.pop(context);
                await auth.logout();
                if (!mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }, color: AppColors.danger),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'v4.0.0 · AgroConecta',
                  style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, VoidCallback onTap, {Color? color}) {
    final textColor = color ?? AppColors.textPrimary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(icon, color: color ?? AppColors.accent, size: 22),
        title: Text(label, style: GoogleFonts.inter(
          color: textColor, fontWeight: FontWeight.w500, fontSize: 14,
        )),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
        onTap: onTap,
        hoverColor: AppColors.accent.withValues(alpha: 0.06),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return ListView(children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.35),
        Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const CircularProgressIndicator(
              color: AppColors.accent,
              backgroundColor: AppColors.bg3,
              strokeWidth: 2.5,
            ),
            const SizedBox(height: 20),
            Text(
              'Cargando publicaciones...',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary, fontSize: 14,
              ),
            ),
          ]),
        ),
      ]);
    }
    if (_error != null) {
      return ListView(children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.15),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: _ErrorState(error: _error!, onRetry: _cargar),
          ),
        ),
      ]);
    }
    if (_pubs.isEmpty) {
      return ListView(children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.15),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: _EmptyState(onPublicar: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CrearPublicacionScreen()),
              );
              _cargar();
            }),
          ),
        ),
      ]);
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 88, 16, 100),
      itemCount: _pubs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (ctx, i) => _AnimatedCard(
        index: i,
        child: PublicacionCard(pub: _pubs[i], mk: _mk, onCompra: _cargar),
      ),
    );
  }
}

/// Wrapper con animación de slide+fade por índice
class _AnimatedCard extends StatefulWidget {
  final Widget child;
  final int index;
  const _AnimatedCard({required this.child, required this.index});

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + widget.index * 60),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _fade,
    child: SlideTransition(position: _slide, child: widget.child),
  );
}

/// Estado de error premium con gradiente y pulso
class _ErrorState extends StatefulWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorState({required this.error, required this.onRetry});

  @override
  State<_ErrorState> createState() => _ErrorStateState();
}

class _ErrorStateState extends State<_ErrorState>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() { _pulseCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2D0A0A), Color(0xFF1A0505)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.danger.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.danger.withValues(alpha: 0.15),
                blurRadius: 24, spreadRadius: 0,
              ),
            ],
          ),
          child: const Icon(Icons.cloud_off_rounded,
              color: AppColors.danger, size: 52),
        ),
        const SizedBox(height: 20),
        Text(
          'No se pudo conectar',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.error,
          style: GoogleFonts.inter(
            color: AppColors.textSecondary, fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        AnimatedBuilder(
          animation: _pulse,
          builder: (ctx, child) => Transform.scale(
            scale: _pulse.value,
            child: child,
          ),
          child: GradientButton(
            onPressed: widget.onRetry,
            gradient: AppGradients.brand,
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text('Reintentar', style: GoogleFonts.plusJakartaSans(
                  fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white,
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Estado vacío premium
class _EmptyState extends StatelessWidget {
  final VoidCallback onPublicar;
  const _EmptyState({required this.onPublicar});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF061624), Color(0xFF0A1A2A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.08),
                blurRadius: 28, spreadRadius: 0,
              ),
            ],
          ),
          child: const Icon(Icons.coffee_rounded, color: AppColors.accent, size: 52),
        ),
        const SizedBox(height: 20),
        Text(
          'Sin publicaciones activas',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sé el primero en publicar sacos de café',
          style: GoogleFonts.inter(
            color: AppColors.textSecondary, fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        GradientButton(
          onPressed: onPublicar,
          gradient: AppGradients.brandGreen,
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text('Publicar saco', style: GoogleFonts.plusJakartaSans(
                fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white,
              )),
            ],
          ),
        ),
      ],
    );
  }
}
