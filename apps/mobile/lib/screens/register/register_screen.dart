// ============================================================
// Register Screen — registro de caficultor con RTN hondureño
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../marketplace/marketplace_screen.dart';

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
    'Lempira', 'Intibucá', 'Santa Bárbara', 'Comayagua', 'Copán',
    'Ocotepeque', 'La Paz', 'Francisco Morazán', 'Cortés', 'Yoro',
    'Atlántida', 'Colón', 'Gracias a Dios', 'El Paraíso', 'Choluteca', 'Valle',
    'Islas de la Bahía', 'Olancho',
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
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MarketplaceScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Error al registrar'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta caficultor')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppGradients.brand,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(children: [
                    const Icon(Icons.person_add_outlined, color: Colors.white, size: 40),
                    const SizedBox(height: 8),
                    Text(
                      'Únete al marketplace',
                      style: TextStyle(
                        color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Conecta directamente con compradores en Honduras',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ]),
                ),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _nombreCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => (v == null || v.length < 3) ? 'Mínimo 3 caracteres' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _rtnCtrl,
                  decoration: const InputDecoration(
                    labelText: 'RTN (14 dígitos)',
                    prefixIcon: Icon(Icons.badge_outlined),
                    helperText: 'Registro Tributario Nacional hondureño',
                    counterText: '',
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 14,
                  validator: (v) {
                    if (v == null || v.length != 14 || int.tryParse(v) == null) {
                      return 'RTN inválido: debe ser 14 dígitos';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || !v.contains('@')) ? 'Email inválido' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _telCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _departamento,
                  decoration: const InputDecoration(
                    labelText: 'Departamento',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  items: _deptos.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: (v) => setState(() => _departamento = v ?? 'Lempira'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    helperText: 'Mínimo 8 caracteres',
                  ),
                  validator: (v) => (v == null || v.length < 8) ? 'Mínimo 8 caracteres' : null,
                ),
                const SizedBox(height: 24),
                if (auth.isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Crear cuenta'),
                  ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: const Text('Ya tengo cuenta — volver a login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
