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
  late Future<List<Ingreso>> _ingresosFuture;
  final numberFormat =
      NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es');
    _cargarIngresos();
  }

  void _cargarIngresos() {
    _ingresosFuture = bd.getModeloIngresos(
        selectedDate.month.toString(), selectedDate.year.toString());
  }

  List<Ingreso> ordenarLista(List<Ingreso> lista) {
    lista.sort((a, b) => int.parse(a.dia).compareTo(int.parse(b.dia)));
    return lista;
  }

  Widget _selectDate(BuildContext context) {
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
                _cargarIngresos();
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

  Widget labelIngreso() {
    final saldo = context.watch<IngresosProvider>().valorIngresoMensual;
    return Text(
      //context.watch<IngresosProvider>().valorIngresoMensual
      "COP ${numberFormat.format(saldo)}",
      style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }

  Widget labelMesCurrent() {
    return Text(
      "Saldo de ${DateFormat.MMMM('es').format(selectedDate)} ${DateFormat.y('es').format(selectedDate)}",
      style: const TextStyle(fontSize: 15),
      textAlign: TextAlign.center,
    );
  }

  Widget labelDiasLaborados() {
    final dias = context.watch<IngresosProvider>().diasLaborados;
    return Text(
      "Dias laborados: $dias",
      style: const TextStyle(
        fontSize: 15,
      ),
      textAlign: TextAlign.center,
    );
  }

  int sumarListaBd(List<Ingreso> lista) {
    return lista.fold(0, (sum, item) => sum + item.monto);
  }

  Widget _createFutureBuilderIngresos() {
    return FutureBuilder<List<Ingreso>>(
      future: _ingresosFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 40),
              const SizedBox(height: 8),
              Text('Error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                  onPressed: () => setState(() => _cargarIngresos()),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'))
            ],
          );
        }
        if (snapshot.hasData) {
          final lista = ordenarLista(snapshot.data!);
          final saldo = sumarListaBd(lista);
          final diasLaborados = lista.length;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.read<IngresosProvider>().setIngresoMensual(saldo);
              context.read<IngresosProvider>().setDiasLaborados(diasLaborados);
            }
          });

          if (lista.isEmpty) {
            return SizedBox.expand(
              child: Container(
                color: const Color(0xffd6d6cd), // mismo color de fondo
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 36,
                      color: Colors.black45,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No hay datos registrados del mes',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(left: 5, bottom: 70),
            shrinkWrap: true,
            itemCount: lista.length,
            itemBuilder: (context, int index) {
              final ingreso = lista[index];
              return Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.monetization_on,
                    size: 30,
                    color: Colors.green,
                  ),
                  title: Text(
                    'COP ${numberFormat.format(ingreso.monto)}',
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  subtitle: Text(
                    DateFormat.yMMMEd('es').format(
                      DateFormat('d-M-yyyy').parse(
                          '${ingreso.dia}-${ingreso.mes}-${ingreso.anio}'),
                    ),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              );
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const AppBarCustomized(),
        body: LayoutBuilder(builder: (context, viewportConstraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: viewportConstraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Container(
                      color: const Color(0xffd6d6cd),
                      width: double.infinity, // ocupa todo el ancho
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          _selectDate(context),
                          labelMesCurrent(),
                          labelIngreso(),
                          labelDiasLaborados(),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: const Color(0xffd6d6cd),
                        height: 200.0,
                        child: _createFutureBuilderIngresos(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }));
  }
}
