import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:taxi_servicios/domain/entitis/estaciongas.dart';
import 'package:taxi_servicios/domain/entitis/gas.dart';
import 'package:taxi_servicios/domain/entitis/ingresos.dart';
import 'package:taxi_servicios/domain/entitis/servicio.dart';
import 'package:taxi_servicios/domain/entitis/variables.dart';

class FireStoreDataBase {
  FirebaseFirestore db = FirebaseFirestore.instance;

/* ignore: slash_for_doc_comments
 CONSULTAS  DE LECTURA BASE DE DATOS 
 */

  Future<List<Variable>> getModeloVariables() async {
    final queryVariables = await db
        .collection('variables')
        .orderBy('valor', descending: true)
        .get();
    final variables = queryVariables.docs.map((e) {
      final model = Variable.fromJson(e.data());
      model.id = e.id;
      return model;
    }).toList();
    return variables;
  }

  Future<List<Servicio>> getModeloServicios(String fecha) async {
    final queryServicios =
        await db.collection('servicios').where('fecha', isEqualTo: fecha).get();

    final servicios = queryServicios.docs.map((e) {
      final modeloServicio = Servicio.fromJson(e.data());
      modeloServicio.id = e.id;
      return modeloServicio;
    }).toList();
    //print('*****SERVIOOSSERVIOSSERVIOS');
    return servicios;
  }

  Future<List<Ingreso>> getModeloIngresos(String mes, String anio) async {
    final queryIngresos = await db
        .collection('ingresos')
        .where('mes', isEqualTo: mes)
        .where('anio', isEqualTo: anio)
        .get();

    final ingresos = queryIngresos.docs.map((e) {
      final modeloIngeso = Ingreso.fromJson(e.data());
      modeloIngeso.id = e.id;
      return modeloIngeso;
    }).toList();
    // ignore: avoid_print

    return ingresos;
  }

  Future<List<EstacionGas>> getModeloEDS() async {
    final queryEDS =
        await db.collection('estacion').orderBy('valorgalon').get();

    final eds = queryEDS.docs.map((e) {
      final modeloEDS = EstacionGas.fromJson(e.data());
      modeloEDS.id = e.id;
      return modeloEDS;
    }).toList();
    // ignore: avoid_print

    return eds;
  }

  Future<List<EstacionGas>> getMejorEDS() async {
    final queryEDS =
        await db.collection('estacion').orderBy('valorgalon').limit(1).get();

    final eds = queryEDS.docs.map((e) {
      final modeloEDS = EstacionGas.fromJson(e.data());
      modeloEDS.id = e.id;
      return modeloEDS;
    }).toList();
    // ignore: avoid_print

    return eds;
  }

  Future<List<GasolineTank>> getModeloTanqueo() async {
    final queryGAS = await db
        .collection('gasolina')
        .orderBy('fecha', descending: true)
        .limit(30)
        .get();

    final gas = queryGAS.docs.map((e) {
      final modeloGasolineTank = GasolineTank.fromJson(e.data());
      modeloGasolineTank.id = e.id;
      return modeloGasolineTank;
    }).toList();
    // ignore: avoid_print

    return gas;
  }

  Future<void> averageValorTanqueo() async {}

//CONSULTAS DE AGREGACION BASE DE DATOS FIREBASE
  Future<void> addVariableBD(int monto, String nombre) async {
    Map<String, dynamic> variable = {"valor": monto, "nombre": nombre};
    await db.collection('variables').doc().set(variable);
  }

  Future<void> addServicioBD(
      String fecha, String hora, int valor, bool facturada) async {
    Map<String, dynamic> servicio = {
      "fecha": fecha,
      "hora": hora,
      "valor": valor,
      "facturada": facturada
    };
    await db.collection('servicios').doc().set(servicio);
  }

  Future<void> addTanqueoBD(
      int valor, int km, double galones, String fecha, String hora) async {
    Map<String, dynamic> tanqueo = {
      "valor": valor,
      "km": km,
      "galones": galones,
      "fecha": fecha,
      "hora": hora,
    };
    await db.collection('gasolina').doc().set(tanqueo);
  }

  Future<void> addGananciaBD(
      int valor, String dia, String mes, String anio) async {
    Map<String, dynamic> ganancia = {
      "dia": dia,
      "mes": mes,
      "anio": anio,
      "monto": valor
    };

    await db.collection('ingresos').doc().set(ganancia);
  }

  Future<void> addEDS(String nombre, String barrio, int valorGalon) async {
    Map<String, dynamic> eds = {
      "barrio": barrio,
      "nombre": nombre,
      "valorgalon": valorGalon
    };
    await db.collection('estacion').doc().set(eds);
  }

//**********/

/*CONSULTAS DE ELIMINACION FIREBASE*/
//Eliminar Servicio
  Future<String> eliminarServicio(String id) async {
    await db.collection('servicios').doc(id).delete();
    return "Eliminadoo....***";
  }

  Future<String> eliminarVariable(String id) async {
    await db.collection('variables').doc(id).delete();
    return "Eliminandoo....***";
  }

  Future<String> eliminarEDS(String id) async {
    await db.collection('estacion').doc(id).delete();
    return "Eliminandoo....***";
  }

  /*CONSULTAS ACTUALIZACION FIREBASE APPTAX */

  Future<void> actualizarVariable(Variable variable) async {
    await db.collection('variables').doc(variable.id).set(variable.toJson());
  }

  Future<void> actualizarServicio(Servicio servicio) async {
    await db.collection('servicios').doc(servicio.id).set(servicio.toJson());
  }

  Future<void> actualizarEDS(EstacionGas eds) async {
    await db.collection('estacion').doc(eds.id).set(eds.toJson());
  }

  // Future<void> actualizarEstadoServicio(String fecha) async {
  //   await FirebaseFirestore.instance
  //       .collection('servicios')
  //       .where('fecha', isEqualTo: fecha)
  //       .get()
  //       .then((value) => value.docs.forEach((element) {
  //             var docRef = FirebaseFirestore.instance
  //                 .collection('servicios')
  //                 .doc(element.id);
  //             docRef.update({'facturada': true});
  //           }));
  // }

  Future<void> actualizarEstadoServicio(String fecha) async {
    // Obtener todos los documentos de la colección 'servicios' donde el campo 'fecha' es igual al valor proporcionado
    var querySnapshot = await FirebaseFirestore.instance
        .collection('servicios')
        .where('fecha', isEqualTo: fecha)
        .get();

    // Iterar sobre cada documento y actualizar el campo 'facturada' a true
    for (var doc in querySnapshot.docs) {
      var docRef =
          FirebaseFirestore.instance.collection('servicios').doc(doc.id);
      await docRef.update({'facturada': true});
    }
  }

  /*CONSULLTAS DE AGREGACION*/

  Future<String> promedioKM() async {
    // ignore: unused_local_variable
    final coll = db.collection('gasolina');

    return 'agregando';
  }

  //Metodo para agregar una nueva columna a todos los documentos de una coleccion

  // Future<void> agregarColumna() async {
  //   await FirebaseFirestore.instance
  //       .collection('servicios')
  //       .get()
  //       .then((value) => value.docs.forEach((element) {
  //             var docRef = FirebaseFirestore.instance
  //                 .collection('servicios')
  //                 .doc(element.id);
  //             docRef.update({'facturada': true});
  //           }));
  // }

  //Metodo para agregar una nueva columna a todos los documentos de una coleccion

  Future<void> agregarColumna() async {
    // Obtener todos los documentos de la colección 'servicios'
    var querySnapshot =
        await FirebaseFirestore.instance.collection('servicios').get();

    // Iterar sobre cada documento y actualizar el campo 'facturada' a true
    for (var i = 0; i < querySnapshot.docs.length; i++) {
      var doc = querySnapshot.docs[i];
      var docRef =
          FirebaseFirestore.instance.collection('servicios').doc(doc.id);
      await docRef.update({'facturada': true});
    }
  }

  // metodo para actulizar la fecha en una coleccion

  Future<void> actualizarFormatoFechas() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('gasolina').get();

    for (var doc in querySnapshot.docs) {
      String fechaAntigua = doc['fecha']; // Suponiendo formato DD-MM-YYYY
      DateTime fecha = DateFormat('dd-MM-yyyy').parse(fechaAntigua);
      String fechaNueva = DateFormat('yyyy-MM-dd').format(fecha);

      await doc.reference.update({'fecha': fechaNueva});
    }
  }
}
