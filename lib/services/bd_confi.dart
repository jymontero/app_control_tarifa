import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;
List _variables = [];
int _metaConfigurada = 0;

List get listaVariablesConfiguracion => _variables;
int get metaConfigurada => _metaConfigurada;

Future<void> getVariables() async {
  _variables = [];
  _metaConfigurada = 0;

  CollectionReference cfVariables = db.collection('variables');

  QuerySnapshot queryVariables = await cfVariables.get();

  for (var item in queryVariables.docs) {
    _variables.add(item.data());
  }
}

Future<void> addVariableBD(int monto, String nombre) async {
  await db.collection('variables').add({"nombre": nombre, "valor": monto});
}

Future<void> addServicioBD(String fecha, String hora, int valor) async {
  await db
      .collection('servicios')
      .add({"fecha": fecha, "hora": hora, "valor": valor});
}

Future<void> addTanqueoBD(int valor, int km, double galones) async {
  await db
      .collection('gasolina')
      .add({"valor": valor, "km": km, "galones": galones});
}

Future<void> addGananciaBD(int valor) async {
  var time = DateTime.now();

  await db.collection('ingresos').add({"fecha": time, "monto": valor});
}
