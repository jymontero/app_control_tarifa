import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pattern_formatter/pattern_formatter.dart';
import 'package:provider/provider.dart';

import '../../../../providers/tanqueo_provider.dart';

class RegistryEntrega extends StatefulWidget {
  const RegistryEntrega({super.key});

  @override
  State<RegistryEntrega> createState() => _RegistryEntregaState();
}

class _RegistryEntregaState extends State<RegistryEntrega> {
  final TextEditingController controllerEntrega =
      TextEditingController(text: "");

  @override
  void initState() {
    controllerEntrega.addListener(() {
      context
          .read<ServicioTanqueoProvider>()
          .setvalorEntrega(controllerEntrega.text);
    });
    super.initState();
  }

  @override
  void dispose() {
    controllerEntrega.dispose();
    super.dispose();
  }

  Widget _createFormEntrega() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextFormField(
          controller: controllerEntrega,
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
              hintText: 'Valor Entrega',
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
              _createFormEntrega(),
            ]),
      ),
    );
  }
}
