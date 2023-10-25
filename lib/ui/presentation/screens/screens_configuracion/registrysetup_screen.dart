// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pattern_formatter/pattern_formatter.dart';
import 'package:provider/provider.dart';
import 'package:taxi_servicios/domain/entitis/variables.dart';
import 'package:taxi_servicios/providers/configuracion_provider.dart';
import 'package:taxi_servicios/services/bd_confi.dart';
import 'package:taxi_servicios/ui/presentation/screens/home_screen.dart';
import 'package:taxi_servicios/ui/presentation/widgets/app_bar.dart';

class RegistryVariable extends StatefulWidget {
  const RegistryVariable({super.key});

  @override
  State<RegistryVariable> createState() => _RegistryVariableState();
}

class _RegistryVariableState extends State<RegistryVariable> {
  final TextEditingController myControllerName =
      TextEditingController(text: "");
  final TextEditingController myControllerValue =
      TextEditingController(text: "");
  final _formKey = GlobalKey<FormState>();

  Widget _createForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: myControllerName,
                keyboardType: TextInputType.text,
                inputFormatters: const [],
                validator: (controller) {
                  if (controller == null || controller.isEmpty) {
                    return 'Ingresa algun texto';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    prefixIcon: Align(
                      widthFactor: 1.0,
                      heightFactor: 1.0,
                      child: Icon(
                        Icons.format_list_bulleted,
                        color: Colors.lightBlue,
                      ),
                    ),
                    helperText: 'Ingrese Nombre',
                    helperStyle: TextStyle(color: Colors.black, fontSize: 15)),
              ),
              TextFormField(
                controller: myControllerValue,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  ThousandsFormatter()
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa algun valor';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    prefixIcon: Align(
                      widthFactor: 1.0,
                      heightFactor: 1.0,
                      child: Icon(
                        Icons.monetization_on,
                        color: Colors.green,
                      ),
                    ),
                    helperText: 'Ingrese valor variable',
                    helperStyle: TextStyle(color: Colors.black, fontSize: 15)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _createRegistryButtom() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.amber),
                foregroundColor: MaterialStateProperty.all(Colors.black),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)))),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final int valor =
                    int.parse(myControllerValue.text.replaceAll(',', ''));
                Variable variable =
                    Variable(valor: valor, nombre: myControllerName.text);
                context.read<ConfiguracionProvider>().addVariable(variable);
                await addVariableBD(valor, myControllerName.text).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content:
                          Text('Configurando variable en el sistema....')));
                  Navigator.pop(context,
                      MaterialPageRoute(builder: (context) => const Home()));
                });
              }

              //Navigator.pop(context, int.parse(myController.text));
            },
            child: const Text('Agregar ',
                style: TextStyle(
                  fontSize: 18,
                )))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const AppBarCustomized(),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Registro De Variable',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
                const Padding(padding: EdgeInsets.all(15)),
                _createForm(),
                const Padding(padding: EdgeInsets.all(20)),
                _createRegistryButtom()
              ]),
        ));
  }
}
