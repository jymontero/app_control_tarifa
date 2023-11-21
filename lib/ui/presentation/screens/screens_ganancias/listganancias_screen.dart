import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ListIngresos extends StatefulWidget {
  const ListIngresos({super.key});

  @override
  State<ListIngresos> createState() => _ListIngresosState();
}

class _ListIngresosState extends State<ListIngresos> {
  late List listaIngresos = [];

  final numberFormat =
      NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 0);

  Widget _createListIngresos(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 5, bottom: 70),
      itemCount: listaIngresos.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          leading: const Icon(
            Icons.table_view,
            size: 30,
            color: Colors.green,
          ),
          title: Text(
            'COP ${numberFormat.format(listaIngresos[index]['valor'])}',
            style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          subtitle: Text(
            '${listaIngresos[index]['nombre']}'.toUpperCase(),
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.mode_edit_outline_outlined,
                    color: Colors.green,
                  )),
              IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.delete_forever, color: Colors.red)),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _createListIngresos(context),
    );
  }
}
