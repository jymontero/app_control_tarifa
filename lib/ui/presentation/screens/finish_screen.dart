import 'package:flutter/material.dart';

class FinishTurn extends StatefulWidget {
  const FinishTurn({super.key});

  @override
  State<FinishTurn> createState() => _FinishTurnState();
}

class _FinishTurnState extends State<FinishTurn> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Text("Finish"),
    );
  }
}
