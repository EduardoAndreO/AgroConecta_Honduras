// ============================================================
// AgroConecta Honduras — Design System v4.0 (Stitch Premium)
// Glassmorphism + Multi-layer gradients + Glow effects
// Fuentes: Plus Jakarta Sans (headlines) + Inter (body)
// ============================================================
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────
// PALETA DE COLORES — Multi-capa
// ─────────────────────────────────────────────────────────────
class AppColors {
  // Base / Fondo (capas profundas)
  static const Color bg0 = Color(0xFF050816); // más oscuro
  static const Color bg1 = Color(0xFF0A0E27); // base
  static const Color bg2 = Color(0xFF0E1A3A); // capa media
  static const Color bg3 = Color(0xFF111935); // surface cards

  // Alias legacy
  static const Color primary     = Color(0xFF0A0E27);
  static const Color primaryDark = Color(0xFF050816);

  // Acento primario — Cyan eléctrico
  static const Color accent       = Color(0xFF06B6D4);
  static const Color accentBright = Color(0xFF4CD7F6);
  static const Color accentSoft   = Color(0xFF67E8F9);
  static const Color accentDim    = Color(0xFF0891B2);

  // Acento secundario — Verde esmeralda
  static const Color green     = Color(0xFF10B981);
  static const Color greenSoft = Color(0xFF34D399);
  static const Color greenDim  = Color(0xFF059669);

  // Superficies
  static const Color bgLight    = Color(0xFFF0F4FF);
  static const Color bgCard     = Color(0xFFFFFFFF);
  static const Color bgCardDark = Color(0xFF111935);
  static const Color bgElevated = Color(0xFF161D3F);

  // Texto
  static const Color textPrimary   = Color(0xFFDFE1F6);
  static const Color textSecondary = Color(0xFFBCC9CD);
  static const Color textMuted     = Color(0xFF869397);
  static const Color textOnLight   = Color(0xFF0F172A);
  static const Color textSecLight  = Color(0xFF475569);

  // Estados
  static const Color success     = Color(0xFF10B981);
  static const Color successSoft = Color(0xFF022C1E);
  static const Color warning     = Color(0xFFF59E0B);
  static const Color warningSoft = Color(0xFF2D1800);
  static const Color danger      = Color(0xFFFF4B4B);
  static const Color dangerSoft  = Color(0xFF2D0A0A);
  static const Color info        = Color(0xFF3B82F6);
  static const Color infoSoft    = Color(0xFF0D1F3C);

  // Bordes
  static const Color border       = Color(0xFF3D494C);
  static const Color borderLight  = Color(0xFFE2E8F0);
  static const Color borderAccent = Color(0xFF06B6D4);

  // Glass
  static Color glassDark  = const Color(0xFF111935).withValues(alpha: 0.85);
  static Color glassLight = const Color(0xFFFFFFFF).withValues(alpha: 0.08);

  // Glow
  static Color glowCyan  = const Color(0xFF06B6D4).withValues(alpha: 0.35);
  static Color glowGreen = const Color(0xFF10B981).withValues(alpha: 0.25);
  static Color glowRed   = const Color(0xFFFF4B4B).withValues(alpha: 0.35);
}

// ─────────────────────────────────────────────────────────────
// GRADIENTES
// ─────────────────────────────────────────────────────────────
class AppGradients {
  static const LinearGradient background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF050816), Color(0xFF0A0E27), Color(0xFF0E1A3A)],
    stops: [0.0, 0.5, 1.0],
  );
  static const LinearGradient brand = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  static const LinearGradient brandGreen = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF10B981)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  static const LinearGradient brandDiagonal = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient cardBorder = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient success = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  static const LinearGradient warning = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  static const LinearGradient danger = LinearGradient(
    colors: [Color(0xFFFF4B4B), Color(0xFFDC2626)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  // Legacy aliases
  static const LinearGradient brandReversed = LinearGradient(
    colors: [Color(0xFF0A0E27), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient card = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// ─────────────────────────────────────────────────────────────
// SOMBRAS / GLOW
// ─────────────────────────────────────────────────────────────
class AppShadows {
  static List<BoxShadow> glowCyan = [
    BoxShadow(
      color: const Color(0xFF06B6D4).withValues(alpha: 0.35),
      blurRadius: 24, spreadRadius: 0, offset: const Offset(0, 8),
    ),
  ];
  static List<BoxShadow> glowGreen = [
    BoxShadow(
      color: const Color(0xFF10B981).withValues(alpha: 0.25),
      blurRadius: 20, spreadRadius: 0, offset: const Offset(0, 6),
    ),
  ];
  static List<BoxShadow> card = [
    BoxShadow(
      color: const Color(0xFF06B6D4).withValues(alpha: 0.08),
      blurRadius: 32, spreadRadius: 0, offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 16, spreadRadius: 0, offset: const Offset(0, 4),
    ),
  ];
  static List<BoxShadow> fab = [
    BoxShadow(
      color: const Color(0xFF06B6D4).withValues(alpha: 0.4),
      blurRadius: 20, spreadRadius: 0, offset: const Offset(0, 6),
    ),
  ];
}

// ─────────────────────────────────────────────────────────────
// TEMA PRINCIPAL
// ─────────────────────────────────────────────────────────────
class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        surface: Color(0xFF0A0E27),
        primary: Color(0xFF06B6D4),
        secondary: Color(0xFF10B981),
        error: Color(0xFFFF4B4B),
      ),
      scaffoldBackgroundColor: AppColors.bg1,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 48, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        headlineSmall: GoogleFonts.plusJakartaSans(
          fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
        bodySmall: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
        labelLarge: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        labelMedium: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bg0,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 64,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          foregroundColor: WidgetStateProperty.all(Colors.white),
          minimumSize: WidgetStateProperty.all(const Size(double.infinity, 54)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          textStyle: WidgetStateProperty.all(
            GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          elevation: WidgetStateProperty.all(0),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
          overlayColor: WidgetStateProperty.all(
            Colors.white.withValues(alpha: 0.1),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accent,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          side: const BorderSide(color: AppColors.accent, width: 1.5),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bg3.withValues(alpha: 0.85),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.accent.withValues(alpha: 0.25)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.accent.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        labelStyle: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14),
        hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
        prefixIconColor: AppColors.accent,
        suffixIconColor: AppColors.textMuted,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: AppColors.bgCardDark,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.border.withValues(alpha: 0.4),
        thickness: 1,
        space: 1,
      ),
      splashFactory: InkRipple.splashFactory,
      splashColor: AppColors.accent.withValues(alpha: 0.1),
      highlightColor: AppColors.accent.withValues(alpha: 0.05),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.bg3,
        contentTextStyle: GoogleFonts.inter(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData dark() => light();
}

// ─────────────────────────────────────────────────────────────
// WIDGETS REUTILIZABLES PREMIUM
// ─────────────────────────────────────────────────────────────

/// Fondo con gradiente multi-capa + glow ambiental
class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.background),
      child: Stack(
        children: [
          Positioned(
            top: -60, right: -60,
            child: Container(
              width: 240, height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF06B6D4).withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -40, left: -40,
            child: Container(
              width: 180, height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF10B981).withValues(alpha: 0.06),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// Card glassmorphism premium con borde gradiente
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final BorderRadius radius;
  final Color? backgroundColor;
  final bool showBorderGradient;
  final List<BoxShadow>? shadow;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = const BorderRadius.all(Radius.circular(20)),
    this.backgroundColor,
    this.showBorderGradient = true,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    Widget inner = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.glassDark,
            borderRadius: radius,
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );

    if (!showBorderGradient) return inner;

    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: AppGradients.cardBorder,
        boxShadow: shadow ?? AppShadows.card,
      ),
      child: Padding(
        padding: const EdgeInsets.all(1.2),
        child: inner,
      ),
    );
  }
}

/// Botón con gradiente y animación de escala en press
class GradientButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Gradient gradient;
  final double height;
  final BorderRadius borderRadius;
  final List<BoxShadow>? shadow;
  final EdgeInsets padding;

  const GradientButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.gradient = AppGradients.brand,
    this.height = 54,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.shadow,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.onPressed?.call(); },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (ctx, child) => Transform.scale(scale: _scale.value, child: child),
        child: Container(
          height: widget.height,
          padding: widget.padding,
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: widget.borderRadius,
            boxShadow: widget.shadow ?? AppShadows.glowCyan,
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}

/// Chip de estado premium con glow
class StatusChip extends StatelessWidget {
  final String label;
  final StatusType type;
  final bool small;

  const StatusChip({
    super.key,
    required this.label,
    this.type = StatusType.neutral,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _colorForType(type);
    final foreground = colors.$1;
    final background = colors.$2;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: small ? 8 : 12, vertical: small ? 4 : 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: foreground.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: foreground.withValues(alpha: 0.15),
            blurRadius: 8, spreadRadius: 0,
          ),
        ],
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: foreground,
          fontSize: small ? 10 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (Color, Color) _colorForType(StatusType t) {
    switch (t) {
      case StatusType.success:
        return (AppColors.success, AppColors.successSoft);
      case StatusType.warning:
        return (AppColors.warning, AppColors.warningSoft);
      case StatusType.danger:
        return (AppColors.danger, AppColors.dangerSoft);
      case StatusType.info:
        return (AppColors.info, AppColors.infoSoft);
      case StatusType.accent:
        return (AppColors.accent, AppColors.accent.withValues(alpha: 0.12));
      case StatusType.neutral:
        return (AppColors.textSecondary, AppColors.border.withValues(alpha: 0.3));
    }
  }
}

enum StatusType { success, warning, danger, info, accent, neutral }

/// Icono en contenedor con gradiente (logo, cards, drawer)
class GradientIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final double containerSize;
  final Gradient gradient;
  final BorderRadius borderRadius;
  final List<BoxShadow>? shadow;

  const GradientIcon({
    super.key,
    required this.icon,
    this.size = 22,
    this.containerSize = 44,
    this.gradient = AppGradients.brandDiagonal,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: borderRadius,
        boxShadow: shadow ?? AppShadows.glowCyan,
      ),
      child: Icon(icon, color: Colors.white, size: size),
    );
  }
}
