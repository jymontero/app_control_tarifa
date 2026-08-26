import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:taxi_servicios/domain/entitis/estaciongas.dart';
import 'package:taxi_servicios/domain/entitis/etiqueta.dart';
import 'package:taxi_servicios/domain/entitis/gas.dart';
import 'package:taxi_servicios/domain/entitis/ingresos.dart';
import 'package:taxi_servicios/domain/entitis/perfil.dart';
import 'package:taxi_servicios/domain/entitis/servicio.dart';
import 'package:taxi_servicios/domain/entitis/turno.dart';
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
  // Future<List<Variable>> getModeloVariables() async {
  //   final querySnapshot = await db
  //       .collection('variables')
  //       .orderBy('valor', descending: true)
  //       .get();

  //   return querySnapshot.docs.map((e) => Variable.fromJson(e.data())).toList();
  // }

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

  Future<List<GasolineTank>> getModeloTanqueoMes(
      {required int month, required int year}) async {
    // El formato de fecha es '2024-02-14' así que filtramos por rango
    final inicio = DateTime(year, month, 1);
    final fin = DateTime(year, month + 1, 1);

    final fechaInicio =
        '${inicio.year}-${inicio.month.toString().padLeft(2, '0')}-${inicio.day.toString().padLeft(2, '0')}';

    final fechaFin =
        '${fin.year}-${fin.month.toString().padLeft(2, '0')}-${fin.day.toString().padLeft(2, '0')}';

    final queryGAS = await db
        .collection('gasolina')
        .where('fecha', isGreaterThanOrEqualTo: fechaInicio)
        .where('fecha', isLessThan: fechaFin)
        .orderBy('fecha', descending: true)
        .get();

    return queryGAS.docs.map((e) {
      final modeloGasolineTank = GasolineTank.fromJson(e.data());
      modeloGasolineTank.id = e.id;
      return modeloGasolineTank;
    }).toList();
  }

  Future<List<GasolineTank>> getTanqueosAnio(int year) async {
    final inicio = '$year-01-01';
    final fin = '${year + 1}-01-01';

    final queryGAS = await db
        .collection('gasolina')
        .where('fecha', isGreaterThanOrEqualTo: inicio)
        .where('fecha', isLessThan: fin)
        .orderBy('fecha', descending: false)
        .get();

    return queryGAS.docs.map((e) {
      final modeloGasolineTank = GasolineTank.fromJson(e.data());
      modeloGasolineTank.id = e.id;
      return modeloGasolineTank;
    }).toList();
  }

//CONSULTAS DE AGREGACION BASE DE DATOS FIREBASE
  Future<void> addVariableBD(int monto, String nombre) async {
    Map<String, dynamic> variable = {"valor": monto, "nombre": nombre};
    await db.collection('variables').doc().set(variable);
  }

  Future<void> addServicioBD(
    String fecha,
    String hora,
    int valor,
    bool facturada,
    String tipoServicio,
    String metodoPago,
  ) async {
    Map<String, dynamic> servicio = {
      "fecha": fecha,
      "hora": hora,
      "valor": valor,
      "facturada": facturada,
      "tipoServicio": tipoServicio,
      "metodoPago": metodoPago,
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
    int valor,
    String dia,
    String mes,
    String anio, {
    int totalBruto = 0,
    int deducciones = 0,
    int numServicios = 0,
    int sueldoObjetivo = 0,
    int totalEfectivo = 0,
    int totalTransferencia = 0,
    int numServiosPagoEfectivo = 0,
    int numServiciosPagoTransferencia = 0,
    int numTipoServicioTaxi = 0,
    int numTipoServicioPlataforma = 0,
  }) async {
    Map<String, dynamic> ganancia = {
      'dia': dia,
      'mes': mes,
      'anio': anio,
      'monto': valor,
      'totalBruto': totalBruto,
      'deducciones': deducciones,
      'numServicios': numServicios,
      'sueldoObjetivo': sueldoObjetivo,
      'totalEfectivo': totalEfectivo,
      'totalTransferencia': totalTransferencia,
      'numServiosPagoEfectivo': numServiosPagoEfectivo,
      'numServiciosPagoTransferencia': numServiciosPagoTransferencia,
      'numTipoServicioTaxi': numTipoServicioTaxi,
      'numTipoServicioPlataforma': numTipoServicioPlataforma,
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

  /// Obtiene el perfil del conductor (documento único)
  Future<Perfil?> getPerfil() async {
    try {
      final doc = await db.collection('perfil').doc('conductor').get();
      if (!doc.exists || doc.data() == null) return null;
      final perfil = Perfil.fromJson(doc.data()!);
      perfil.id = doc.id;
      return perfil;
    } catch (e) {
      return null;
    }
  }

  /// Guarda o actualiza el perfil del conductor
  Future<void> guardarPerfil(Perfil perfil) async {
    await db
        .collection('perfil')
        .doc('conductor')
        .set(perfil.toJson(), SetOptions(merge: true));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ETIQUETAS — agregar a FireStoreDataBase en bd_confi.dart
  // ─────────────────────────────────────────────────────────────────────────

  /// Obtiene todas las etiquetas del conductor
  Future<List<Etiqueta>> getEtiquetas() async {
    final query = await db.collection('etiquetas').orderBy('nombre').get();

    return query.docs.map((e) {
      final etiqueta = Etiqueta.fromJson(e.data());
      etiqueta.id = e.id;
      return etiqueta;
    }).toList();
  }

  /// Crea una nueva etiqueta
  Future<Etiqueta> addEtiqueta(String nombre, String color) async {
    final doc = await db.collection('etiquetas').add({
      'nombre': nombre,
      'color': color,
    });
    final etiqueta = Etiqueta(nombre: nombre, color: color);
    etiqueta.id = doc.id;
    return etiqueta;
  }

  /// Elimina una etiqueta
  Future<void> eliminarEtiqueta(String etiquetaId) async {
    await db.collection('etiquetas').doc(etiquetaId).delete();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TURNOS — agregar a FireStoreDataBase en bd_confi.dart
  // ─────────────────────────────────────────────────────────────────────────

  /// Obtiene todos los turnos de un mes específico
  Future<List<Turno>> getTurnosMes(int mes, int anio) async {
    final inicioStr = '$anio-${mes.toString().padLeft(2, '0')}-01';
    final fin = DateTime(anio, mes + 1, 1);
    final finStr = '${fin.year}-${fin.month.toString().padLeft(2, '0')}-01';

    final query = await db
        .collection('turnos')
        .where('fecha', isGreaterThanOrEqualTo: inicioStr)
        .where('fecha', isLessThan: finStr)
        .get();

    return query.docs.map((e) {
      final turno = Turno.fromJson(e.data());
      turno.id = e.id;
      return turno;
    }).toList();
  }

  /// Agrega una etiqueta a un día
  Future<Turno> addTurno({
    required String fecha,
    required String etiquetaId,
    required String etiquetaNombre,
    required String etiquetaColor,
  }) async {
    final doc = await db.collection('turnos').add({
      'fecha': fecha,
      'etiquetaId': etiquetaId,
      'etiquetaNombre': etiquetaNombre,
      'etiquetaColor': etiquetaColor,
      'confirmado': false,
    });
    final turno = Turno(
      fecha: fecha,
      etiquetaId: etiquetaId,
      etiquetaNombre: etiquetaNombre,
      etiquetaColor: etiquetaColor,
    );
    turno.id = doc.id;
    return turno;
  }

  /// Elimina una etiqueta de un día específico
  Future<void> eliminarTurno(String turnoId) async {
    await db.collection('turnos').doc(turnoId).delete();
  }

  /// Elimina todas las etiquetas de un día
  Future<void> eliminarTurnosDia(String fecha) async {
    final query =
        await db.collection('turnos').where('fecha', isEqualTo: fecha).get();
    for (final doc in query.docs) {
      await doc.reference.delete();
    }
  }

  /// Marca un turno como confirmado (cuando hay ingreso registrado)
  Future<void> confirmarTurno(String fecha) async {
    final query =
        await db.collection('turnos').where('fecha', isEqualTo: fecha).get();
    for (final doc in query.docs) {
      await doc.reference.update({'confirmado': true});
    }
  }
}
