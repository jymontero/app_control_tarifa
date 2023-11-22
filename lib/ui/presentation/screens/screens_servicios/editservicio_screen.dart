// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pattern_formatter/pattern_formatter.dart';
import 'package:provider/provider.dart';
import 'package:taxi_servicios/domain/entitis/servicio.dart';
import 'package:taxi_servicios/providers/contadordeservicios_provider.dart';
import 'package:taxi_servicios/services/bd_confi.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_servicios/listservices_screen.dart';
import 'package:taxi_servicios/ui/presentation/widgets/app_bar.dart';

class EditService extends StatefulWidget {
  Servicio objServicio;
  EditService(this.objServicio, {super.key});

  @override
  State<EditService> createState() => _EditServiceState();
}

class _EditServiceState extends State<EditService> {
  final TextEditingController myControllerValueEdit =
      TextEditingController(text: "");
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    setState(() {
      myControllerValueEdit.text = widget.objServicio.valorservicio.toString();
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
                    helperText: 'Ingrese valor servicio',
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

                Servicio servicio = Servicio(
                    valorservicio: valor,
                    hora: widget.objServicio.hora,
                    fecha: widget.objServicio.fecha);

                servicio.id = widget.objServicio.id;

                await db.actualizarServicio(servicio).then((_) {
                  //context para meta x hacer
                  context
                      .read<ContadorServicioProvider>()
                      .decrementarMetaPorHacer(valor);
                  context
                      .read<ContadorServicioProvider>()
                      .sumarMetaPorHacer(widget.objServicio.valorservicio);

                  //context para metaObtenida

                  context
                      .read<ContadorServicioProvider>()
                      .decrementarMetaObtendia(
                          widget.objServicio.valorservicio);

                  context
                      .read<ContadorServicioProvider>()
                      .incrementarMetaObtenida(valor);

                  //
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content:
                          Text('Actualizando valores de los SERVICIOS....')));
                  Navigator.pop(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ListService()));
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
                      'Editar Servicio',
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
