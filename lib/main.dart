import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:taxi_servicios/providers/perfil_provider.dart';
import 'package:taxi_servicios/providers/reportes_provider.dart';

import 'firebase_options.dart';
import 'package:taxi_servicios/providers/configuracion_provider.dart';
import 'package:taxi_servicios/providers/contadordeservicios_provider.dart';
import 'package:taxi_servicios/providers/ingresos_provider.dart';
import 'package:taxi_servicios/providers/tanqueo_provider.dart';
import 'package:taxi_servicios/providers/theme_provider.dart';
import 'package:taxi_servicios/ui/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConfiguracionProvider()),
        ChangeNotifierProvider(create: (_) => ContadorServicioProvider()),
        ChangeNotifierProvider(create: (_) => ServicioTanqueoProvider()),
        ChangeNotifierProvider(create: (_) => IngresosProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => PerfilProvider()),
        ChangeNotifierProvider(create: (_) => ReportesProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (_, themeProvider, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          // ── Tema claro ──────────────────────────────────────────────────────
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFFF5C518),
            brightness: Brightness.light,
          ),

          // ── Tema oscuro — Dark Premium ──────────────────────────────────────
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFF5C518),
              brightness: Brightness.dark,
              background: const Color(0xFF0F1923),
              surface: const Color(0xFF1A2535),
              primary: const Color(0xFFF5C518),
              onPrimary: const Color(0xFF0F1923),
              onBackground: const Color(0xFFF1F5F9),
              onSurface: const Color(0xFFF1F5F9),
            ),
            scaffoldBackgroundColor: const Color(0xFF0F1923),
            cardColor: const Color(0xFF1A2535),
            dividerColor: const Color(0xFF1E2D3D),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0D1F2D),
              foregroundColor: Color(0xFFF1F5F9),
              elevation: 0,
            ),
          ),

          // ── Modo activo según ThemeProvider ────────────────────────────────
          themeMode: themeProvider.themeMode,

          // ── Localización ───────────────────────────────────────────────────
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('es'),
          ],

          home: const Home(),
        );
      },
    );
  }
}
