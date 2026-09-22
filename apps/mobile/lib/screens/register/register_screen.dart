// ============================================================
// Register Screen — Stitch Premium v4.0
// Fondo multi-capa + AppBackground + GlassCard + GradientButton
// ============================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _rtnCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telCtrl = TextEditingController(text: '+504 ');
  final _passCtrl = TextEditingController();
  String _departamento = 'Lempira';
  bool _obscure = true;

  static const _deptos = [
    'Lempira',
    'Intibucá',
    'Santa Bárbara',
    'Comayagua',
    'Copán',
    'Ocotepeque',
    'La Paz',
    'Francisco Morazán',
    'Cortés',
    'Yoro',
    'Atlántida',
    'Colón',
    'Gracias a Dios',
    'El Paraíso',
    'Choluteca',
    'Valle',
    'Islas de la Bahía',
    'Olancho',
  ];

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _rtnCtrl.dispose();
    _emailCtrl.dispose();
    _telCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthService>();
    final ok = await auth.register(
      nombre: _nombreCtrl.text.trim(),
      rtn: _rtnCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      telefono: _telCtrl.text.trim(),
      password: _passCtrl.text,
      departamento: _departamento,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Error al registrar'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    return Scaffold(
      backgroundColor: AppColors.bg0,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Crear cuenta',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero Card con Gradiente sutil y glow
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
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1.5),
                          ),
                          child: const Icon(Icons.person_add_alt_1_rounded,
                              color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Únete al Marketplace',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Conecta con compradores de café en toda Honduras sin intermediarios.',
                                style: GoogleFonts.inter(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Card contenedor de formulario
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    radius: BorderRadius.circular(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Datos del productor',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nombreCtrl,
                          style: GoogleFonts.inter(
                              color: Colors.white, fontSize: 14),
                          decoration: const InputDecoration(
                            labelText: 'Nombre completo',
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                          validator: (v) => (v == null || v.length < 3)
                              ? 'Mínimo 3 caracteres'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _rtnCtrl,
                          style: GoogleFonts.inter(
                              color: Colors.white, fontSize: 14),
                          decoration: const InputDecoration(
                            labelText: 'RTN (14 dígitos)',
                            prefixIcon: Icon(Icons.badge_outlined),
                            helperText:
                                'Registro Tributario Nacional hondureño',
                            counterText: '',
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 14,
                          validator: (v) {
                            if (v == null ||
                                v.length != 14 ||
                                int.tryParse(v) == null) {
                              return 'RTN inválido: debe tener 14 dígitos';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailCtrl,
                          style: GoogleFonts.inter(
                              color: Colors.white, fontSize: 14),
                          decoration: const InputDecoration(
                            labelText: 'Correo electrónico',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => (v == null || !v.contains('@'))
                              ? 'Email inválido'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _telCtrl,
                          style: GoogleFonts.inter(
                              color: Colors.white, fontSize: 14),
                          decoration: const InputDecoration(
                            labelText: 'Teléfono',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _departamento,
                          dropdownColor: AppColors.bg2,
                          style: GoogleFonts.inter(
                              color: Colors.white, fontSize: 14),
                          decoration: const InputDecoration(
                            labelText: 'Departamento cafetalero',
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                          items: _deptos
                              .map((d) => DropdownMenuItem(
                                    value: d,
                                    child: Text(d,
                                        style: GoogleFonts.inter(
                                            color: Colors.white)),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _departamento = v ?? 'Lempira'),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: _obscure,
                          style: GoogleFonts.inter(
                              color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.textMuted,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                            helperText: 'Mínimo 8 caracteres',
                          ),
                          validator: (v) => (v == null || v.length < 8)
                              ? 'Mínimo 8 caracteres'
                              : null,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (auth.isLoading)
                    const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accent,
                        backgroundColor: AppColors.bg3,
                      ),
                    )
                  else
                    GradientButton(
                      gradient: AppGradients.brandDiagonal,
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        _submit();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Crear cuenta de caficultor',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded,
                        size: 16, color: AppColors.accentSoft),
                    label: Text(
                      'Ya tengo cuenta — Iniciar sesión',
                      style: GoogleFonts.inter(
                        color: AppColors.accentSoft,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
