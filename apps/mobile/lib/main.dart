// ============================================================
// AgroConecta Honduras — App Móvil Flutter
// main.dart — entrypoint
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'theme/app_theme.dart';
import 'screens/login/login_screen.dart';
import 'screens/marketplace/marketplace_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // Base URL configurable: 10.0.2.2 = host local desde emulador Android
  // Para web/iOS: usa localhost. Para device físico: IP de tu PC en la red.
  const baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService(baseUrl: baseUrl)),
        ChangeNotifierProvider<AuthService>(
          create: (ctx) => AuthService(prefs: prefs, api: ctx.read<ApiService>()),
        ),
      ],
      child: const AgroConectaApp(),
    ),
  );
}

class AgroConectaApp extends StatelessWidget {
  const AgroConectaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgroConecta Honduras',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: Consumer<AuthService>(
        builder: (ctx, auth, _) {
          if (auth.isAuthenticated) {
            return const MarketplaceScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
