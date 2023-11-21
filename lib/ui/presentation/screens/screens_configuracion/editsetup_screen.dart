// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pattern_formatter/pattern_formatter.dart';
import 'package:provider/provider.dart';
import 'package:taxi_servicios/domain/entitis/variables.dart';
import 'package:taxi_servicios/providers/configuracion_provider.dart';
import 'package:taxi_servicios/providers/contadordeservicios_provider.dart';
import 'package:taxi_servicios/services/bd_confi.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_configuracion/listvariables_screen.dart';
import 'package:taxi_servicios/ui/presentation/widgets/app_bar.dart';

class EditVariable extends StatefulWidget {
  Variable objVariable;
  EditVariable(this.objVariable, {super.key});

  @override
  State<EditVariable> createState() => _EditVariableState();
}

class _EditVariableState extends State<EditVariable> {
  final TextEditingController myControllerNameEdit =
      TextEditingController(text: "");
  final TextEditingController myControllerValueEdit =
      TextEditingController(text: "");
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    setState(() {
      myControllerNameEdit.text = widget.objVariable.nombre;
      myControllerValueEdit.text = widget.objVariable.valor.toString();
    });
    super.initState();
  }

  FireStoreDataBase db = FireStoreDataBase();

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
                style: const TextStyle(fontWeight: FontWeight.bold),
                controller: myControllerNameEdit,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
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
                style: const TextStyle(fontWeight: FontWeight.bold),
                controller: myControllerValueEdit,
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

  Widget _createEtidButtom(BuildContext context) {
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
                    int.parse(myControllerValueEdit.text.replaceAll(',', ''));
                Variable variable =
                    Variable(valor: valor, nombre: myControllerNameEdit.text);
                variable.id = widget.objVariable.id;

                await db.actualizarVariable(variable).then((_) {
                  //context para metaregistrada
                  context
                      .read<ConfiguracionProvider>()
                      .restaVariable(widget.objVariable.valor);
                  context.read<ConfiguracionProvider>().sumarVariable(valor);

                  //context para meta x hacer

                  context
                      .read<ContadorServicioProvider>()
                      .decrementarMetaPorHacer(widget.objVariable.valor);
                  context
                      .read<ContadorServicioProvider>()
                      .sumarMetaPorHacer(valor);

                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content:
                          Text('Configurando variable en el sistema....')));
                  Navigator.pop(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Configuration()));
                });
              }

              //Navigator.pop(context, int.parse(myController.text));
            },
            child: const Text('Actualizar ',
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
                      'Editar Variable',
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
                _createEtidButtom(context)
              ]),
        ));
  }
}
