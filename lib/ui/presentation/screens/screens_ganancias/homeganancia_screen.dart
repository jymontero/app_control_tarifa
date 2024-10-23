import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:taxi_servicios/domain/entitis/ingresos.dart';
import 'package:taxi_servicios/providers/ingresos_provider.dart';
import 'package:taxi_servicios/ui/presentation/widgets/app_bar.dart';
import 'package:taxi_servicios/services/bd_confi.dart';
import 'package:mat_month_picker_dialog/mat_month_picker_dialog.dart';
// for date format
import 'package:intl/date_symbol_data_local.dart';

class HomeGanancia extends StatefulWidget {
  const HomeGanancia({super.key});

  @override
  State<HomeGanancia> createState() => _HomeGananciaState();
}

class _HomeGananciaState extends State<HomeGanancia> {
  FireStoreDataBase bd = FireStoreDataBase();
  DateTime selectedDate = DateTime.now().toLocal();
  late List<Ingreso> listaIngresos = [];
  final numberFormat =
      NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 0);

  @override
  void initState() {
    initializeDateFormatting('es');
    super.initState();
  }

  List<Ingreso> ordenarLista(List<Ingreso> lista) {
    lista.sort((a, b) => int.parse(a.dia).compareTo(int.parse(b.dia)));
    return lista;
  }

  Widget _selectDate(BuildContext context, String locale) {
    return SizedBox(
      child: TextButton.icon(
          onPressed: () async {
            final DateTime? selected = await showMonthPicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2022),
                lastDate: DateTime(2030),
                locale: const Locale('es'));

            if (selected != null && selected != selectedDate) {
              setState(() {
                selectedDate = selected;
              });
            }
          },
          icon: const Icon(
            Icons.calendar_month,
            size: 22,
            color: Colors.black,
          ),
          label: Text(
            DateFormat.MMMM('es').format(selectedDate),
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          )),
    );
  }

  Widget labelIngreso(int ingresoMes) {
    return Text(
      //context.watch<IngresosProvider>().valorIngresoMensual
      "COP ${numberFormat.format(ingresoMes)}",

      style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }

  Widget labelIngrsoProv() {
    final provider = Provider.of<IngresosProvider>(context, listen: false);
    return Text(
      provider.valorIngresoMensual.toString(),
      style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }

  Widget labelMesCurrent() {
    return Text(
      "Saldo del mes ${DateFormat.MMMM('es').format(selectedDate)}",
      style: const TextStyle(fontSize: 15),
      textAlign: TextAlign.center,
    );
  }

  int sumarListaBd(List<Ingreso> lista) {
    listaIngresos = lista;
    int sumar = 0;
    for (var item in listaIngresos) {
      int aux = item.monto;
      sumar += aux;
    }

    return sumar;
  }

  Widget _createFutureBuilderIngresos(String mes, String anio) {
    return FutureBuilder(
        future: bd.getModeloIngresos(mes, anio),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("AlgoMaloPaso");
          }
          if (snapshot.hasData) {
            listaIngresos = snapshot.data!;
            listaIngresos = ordenarLista(listaIngresos);

            return _createListIngresos(context);
          }

          return const Center(child: CircularProgressIndicator());
        });
  }

  Widget _createListIngresos(BuildContext context) {
    int saldo = sumarListaBd(listaIngresos);

    Future.microtask(() {
      context.read<IngresosProvider>().setIngresoMensual(saldo);
    });
    if (listaIngresos.isEmpty) {
      return const Text(
        'No hay datos Registrados  del mes',
        textAlign: TextAlign.center,
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.only(left: 5, bottom: 70),
        shrinkWrap: true,
        itemCount: listaIngresos.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            //margin: const EdgeInsets.all(5),
            child: Column(children: <Widget>[
              ListTile(
                leading: const Icon(
                  Icons.monetization_on,
                  size: 30,
                  color: Colors.green,
                ),
                title: Text(
                  'COP ${numberFormat.format(listaIngresos[index].monto)}',
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                subtitle: Text(
                  DateFormat.yMMMEd('es').format(DateFormat('d-M-yyyy').parse(
                      '${listaIngresos[index].dia}-${listaIngresos[index].mes}-${listaIngresos[index].anio}')),
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                ),
              )
            ]),
          );
        },
      );
    }
  }

  Widget _crearUI(BuildContext context) {
    final providerSS = Provider.of<IngresosProvider>(context, listen: false);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: viewportConstraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  Container(
                    // A fixed-height child.
                    color: const Color(0xffd6d6cd), // Yellow
                    height: 120.0,
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        _selectDate(context, 'es'),
                        labelMesCurrent(),
                        labelIngreso(providerSS.valorIngresoMensual),
                      ],
                    ),
                  ),
                  Expanded(
                    // A flexible child that will grow to fit the viewport but
                    // still be at least as big as necessary to fit its contents.
                    child: Container(
                        color: const Color.fromARGB(255, 206, 214, 205),
                        height: 200.0,
                        alignment: Alignment.center,
                        child: _createFutureBuilderIngresos(
                            selectedDate.month.toString(),
                            selectedDate.year.toString())),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarCustomized(),
      body: _crearUI(context),
    );
  }
}


/**
 * 
 * Scaffold(
        appBar: const AppBarCustomized(),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                child: Column(
                  children: [
                    _selectDate(context),
                    saldoMes(),
                    labelIngreso(
                        context.watch<IngresosProvider>().valorIngresoMensual),
                  ],
                ),
              ),
              _createFutureBuilderIngresos(selectedDate.month.toString())
            ],
          ),
        ));
 */
