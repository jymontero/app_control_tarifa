import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pattern_formatter/pattern_formatter.dart';
import 'package:provider/provider.dart';

import '../../../../providers/tanqueo_provider.dart';

class RegistryLavada extends StatefulWidget {
  const RegistryLavada({super.key});

  @override
  State<RegistryLavada> createState() => _RegistryLavadaState();
}

class _RegistryLavadaState extends State<RegistryLavada> {
  final TextEditingController controllerLavada =
      TextEditingController(text: "");

  @override
  void initState() {
    controllerLavada.addListener(() {
      context
          .read<ServicioTanqueoProvider>()
          .setvalorLavada(controllerLavada.text);
    });
    super.initState();
  }

  @override
  void dispose() {
    controllerLavada.dispose();
    super.dispose();
  }

  Widget _createFormLavada() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextFormField(
          controller: controllerLavada,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
            ThousandsFormatter()
          ],
          decoration: const InputDecoration(
              prefixIcon: Align(
                widthFactor: 1.0,
                heightFactor: 1.0,
                child: Icon(
                  Icons.monetization_on,
                  color: Colors.green,
                ),
              ),
              hintText: 'Valor Lavada',
              hintStyle: TextStyle(color: Colors.black38, fontSize: 14)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [],
              ),
              _createFormLavada(),
            ]),
      ),
    );
  }
}
