import 'package:flutter/material.dart';

class FinishTurn extends StatefulWidget {
  const FinishTurn({super.key});

  @override
  State<FinishTurn> createState() => _FinishTurnState();
}

class _FinishTurnState extends State<FinishTurn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Text('data'),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'btnFinalizarTurno',
        backgroundColor: Colors.red,
        onPressed: () {},
        icon: const Icon(
          Icons.output_outlined,
        ),
        label: const Text('Finalizar Turno'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
