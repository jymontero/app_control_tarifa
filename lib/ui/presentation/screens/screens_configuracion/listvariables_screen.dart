import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:taxi_servicios/domain/entitis/variables.dart';
import 'package:taxi_servicios/providers/configuracion_provider.dart';
import 'package:taxi_servicios/providers/contadordeservicios_provider.dart';
import 'package:taxi_servicios/services/bd_confi.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_configuracion/editsetup_screen.dart';
import 'package:taxi_servicios/ui/presentation/screens/screens_configuracion/registrysetup_screen.dart';

class Configuration extends StatefulWidget {
  const Configuration({super.key});

  @override
  State<Configuration> createState() => _ConfigurationState();
}

class _ConfigurationState extends State<Configuration> {
  FireStoreDataBase bd = FireStoreDataBase();

  late List<Variable> listaVariablesConfig = [];
  final numberFormat =
      NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
  }

  Widget _createListVariable(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 5, bottom: 70),
      itemCount: listaVariablesConfig.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          leading: const Icon(
            Icons.table_view,
            size: 30,
            color: Colors.purple,
          ),
          title: Text(
            'COP ${numberFormat.format(listaVariablesConfig[index].valor)}',
            style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          subtitle: Text(
            listaVariablesConfig[index].nombre,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  onPressed: () {
                    Variable objVariable = listaVariablesConfig[index];

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditVariable(objVariable)));
                  },
                  icon: const Icon(
                    Icons.mode_edit_outline_outlined,
                    color: Colors.green,
                  )),
              IconButton(
                  onPressed: () {
                    int valor = listaVariablesConfig[index].valor;
                    context.read<ConfiguracionProvider>().restaVariable(valor);
                    context
                        .read<ContadorServicioProvider>()
                        .decrementarMetaPorHacer(valor);
                    bd.eliminarVariable(listaVariablesConfig[index].id);
                  },
                  icon: const Icon(Icons.delete_forever, color: Colors.red)),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                SizedBox(
                  height: 5,
                ),
                Text(
                  "Variables De",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Configuración',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                )
              ],
            )
          ],
        )),
        body: FutureBuilder(
          future: bd.getModeloVariables(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text("Algo malo Ocurrio");
            }
            if (snapshot.hasData) {
              listaVariablesConfig = snapshot.data!;

              return _createListVariable(context);
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'btnagregar',
          backgroundColor: Colors.green,
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const RegistryVariable()));
          },
          icon: const Icon(Icons.playlist_add),
          label: const Text('Agregar Variable'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat);
  }
}
