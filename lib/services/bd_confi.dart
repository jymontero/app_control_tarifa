import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;
List _variables = [];

List get listaVariablesConfiguracion => _variables;

Future<List> getVariables() async {
  CollectionReference cfVariables = db.collection('variables');

  QuerySnapshot queryVariables = await cfVariables.get();

  for (var item in queryVariables.docs) {
    _variables.add(item.data());
  }
  return _variables;
}

Future<void> addVariableBD(int monto, String nombre) async {
  await db.collection('variables').add({"nombre": nombre, "valor": monto});
}

Future<void> addServicioBD(String fecha, String hora, int valor) async {
  await db
      .collection('servicios')
      .add({"fecha": fecha, "hora": hora, "valor": valor});
}
