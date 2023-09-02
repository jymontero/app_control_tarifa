import 'package:flutter/material.dart';

class Gasoline extends StatefulWidget {
  const Gasoline({super.key});

  @override
  State<Gasoline> createState() => _GasolineState();
}

class _GasolineState extends State<Gasoline> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Text("Gas"),
    );
  }
}
