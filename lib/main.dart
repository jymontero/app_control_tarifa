import 'package:flutter/material.dart';
import 'package:taxi_servicios/providers/configuracion_provider.dart';
import 'package:taxi_servicios/providers/contadordeservicios_provider.dart';
import 'package:taxi_servicios/providers/ingresos_provider.dart';
import 'package:taxi_servicios/providers/tanqueo_provider.dart';
import 'package:taxi_servicios/ui/presentation/screens/home_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => ConfiguracionProvider()),
    ChangeNotifierProvider(create: (_) => ContadorServicioProvider()),
    ChangeNotifierProvider(create: (_) => ServicioTanqueoProvider()),
    ChangeNotifierProvider(create: (_) => IngresosProvider())
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme:
          ThemeData(useMaterial3: true, colorSchemeSeed: Colors.amber.shade600),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es'), // Spanish
      ],
      home: const Home(),
    );
  }
}
