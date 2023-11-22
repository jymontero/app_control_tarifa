import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:taxi_servicios/domain/entitis/ingresos.dart';
import 'package:taxi_servicios/providers/ingresos_provider.dart';
import 'package:taxi_servicios/ui/presentation/widgets/app_bar.dart';
import 'package:taxi_servicios/services/bd_confi.dart';

// for date format
import 'package:intl/date_symbol_data_local.dart';

class HomeGanancia extends StatefulWidget {
  const HomeGanancia({super.key});

  @override
  State<HomeGanancia> createState() => _HomeGananciaState();
}

class _HomeGananciaState extends State<HomeGanancia> {
  String date = "";
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

  int sumarListaBd(List<Ingreso> lista) {
    listaIngresos = lista;
    int sumar = 0;
    for (var item in listaIngresos) {
      int aux = item.monto;
      sumar += aux;
    }
    return sumar;
  }

  Widget _createFutureBuilderIngresos(String fecha) {
    return FutureBuilder(
        future: bd.getModeloIngresos(fecha),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("AlgoMaloPaso");
          }
          if (snapshot.hasData) {
            listaIngresos = snapshot.data!;
            int ingresoMensual = sumarListaBd(listaIngresos);
            Future.microtask(() {
              context
                  .read<IngresosProvider>()
                  .setIngresoMensual(ingresoMensual);
            });
            return _createListIngresos(context);
          }
          return const Center(child: CircularProgressIndicator());
        });
  }

  Widget _createListIngresos(BuildContext context) {
    if (listaIngresos.isEmpty) {
      return const Text(
        'No hay datos Registrados  del mes',
        textAlign: TextAlign.center,
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.only(left: 5, bottom: 70),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: listaIngresos.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: const Icon(
              Icons.check_circle,
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
              '${listaIngresos[index].dia}-${listaIngresos[index].mes}-${listaIngresos[index].anio}',
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
          );
        },
      );
    }
  }

  Widget labelIngreso(int ingreso) {
    return Text(
      "COP ${numberFormat.format(ingreso)}",
      style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }

  Widget _selectDate(BuildContext context) {
    return SizedBox(
      child: TextButton.icon(
          onPressed: () async {
            final DateTime? selected = await showDatePicker(
              context: context,
              locale: const Locale('es'),
              initialDate: selectedDate,
              firstDate: DateTime(2022),
              lastDate: DateTime(2030),
              initialEntryMode: DatePickerEntryMode.calendarOnly,
            );
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

  Widget saldoMes() {
    return Text(
      "Saldo del mes ${DateFormat.MMMM('es').format(selectedDate)}",
      style: const TextStyle(fontSize: 15),
      textAlign: TextAlign.center,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
  }
}
