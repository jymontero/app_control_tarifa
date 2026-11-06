import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taxi_servicios/domain/entitis/estaciongas.dart';
import 'package:taxi_servicios/domain/entitis/etiqueta.dart';
import 'package:taxi_servicios/domain/entitis/gas.dart';
import 'package:taxi_servicios/domain/entitis/ingresos.dart';
import 'package:taxi_servicios/domain/entitis/movimiento_presupuesto.dart';
import 'package:taxi_servicios/domain/entitis/perfil.dart';
import 'package:taxi_servicios/domain/entitis/plantilla_item.dart';
import 'package:taxi_servicios/domain/entitis/presupuesto_item.dart';
import 'package:taxi_servicios/domain/entitis/presupuesto_mensual.dart';
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
    String metodoPago, {
    double kmRecorridos = 0,
    String nombreInicio = '',
    String nombreFin = '',
    GeoPoint? puntoInicio,
    GeoPoint? puntoFin,
    List<GeoPoint> rutaPuntos = const [],
  }) async {
    Map<String, dynamic> servicio = {
      "fecha": fecha,
      "hora": hora,
      "valor": valor,
      "facturada": facturada,
      "tipoServicio": tipoServicio,
      "metodoPago": metodoPago,
      // Campos tracking — solo se guardan si tienen valor
      if (kmRecorridos > 0) 'kmRecorridos': kmRecorridos,
      if (nombreInicio.isNotEmpty) 'nombreInicio': nombreInicio,
      if (nombreFin.isNotEmpty) 'nombreFin': nombreFin,
      if (puntoInicio != null) 'puntoInicio': puntoInicio,
      if (puntoFin != null) 'puntoFin': puntoFin,
      if (rutaPuntos.isNotEmpty) 'rutaPuntos': rutaPuntos,
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

  // ── Plantilla ─────────────────────────────────────────────────────

  Future<List<PlantillaItem>> getPlantilla() async {
    final query =
        await db.collection('plantilla_presupuesto').orderBy('orden').get();
    return query.docs.map((e) {
      final item = PlantillaItem.fromJson(e.data());
      item.id = e.id;
      return item;
    }).toList();
  }

  Future<void> addPlantillaItem(String nombre, int planBase, int orden) async {
    await db.collection('plantilla_presupuesto').add({
      'nombre': nombre,
      'planBase': planBase,
      'orden': orden,
    });
  }

  Future<void> updatePlantillaItem(String id, int planBase) async {
    await db.collection('plantilla_presupuesto').doc(id).update({
      'planBase': planBase,
    });
  }

  Future<void> deletePlantillaItem(String id) async {
    await db.collection('plantilla_presupuesto').doc(id).delete();
  }

// ── Presupuesto mensual ───────────────────────────────────────────

  Future<PresupuestoMensual?> getPresupuestoMensual(
    String mes,
    String anio,
  ) async {
    // ── Buscar presupuesto del mes ───────────────────────────────
    final query = await db
        .collection('presupuesto_mensual')
        .where('mes', isEqualTo: mes)
        .where('anio', isEqualTo: anio)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;

    // ── Construir presupuesto ────────────────────────────────────
    final doc = query.docs.first;

    final presupuesto = PresupuestoMensual.fromJson(doc.data());
    presupuesto.id = doc.id;

    // ── Cargar items ─────────────────────────────────────────────
    final itemsQuery =
        await doc.reference.collection('items').orderBy('orden').get();

    presupuesto.items = itemsQuery.docs.map((e) {
      final item = PresupuestoItem.fromJson(e.data());
      item.id = e.id;
      return item;
    }).toList();

    return presupuesto;
  }

// Crea presupuesto nuevo desde plantilla

  Future<PresupuestoMensual> crearPresupuestoDesdePlantilla(
    String mes,
    String anio, {
    int ahorroAnterior = 0,
    int diasPlanificados = 0,
    List<String> etiquetasContables = const [],
  }) async {
    // ── Obtener plantilla ────────────────────────────────────────
    final plantilla = await getPlantilla();

    if (plantilla.isEmpty) {
      throw StateError(
        'No existe una plantilla de presupuesto.',
      );
    }

    // ── Calcular valores ─────────────────────────────────────────
    final totalPlan = plantilla.fold<int>(
      0,
      (s, item) => s + item.planBase,
    );

    final totalACubrir = totalPlan - ahorroAnterior;

    final metaOriginal =
        diasPlanificados > 0 ? (totalACubrir / diasPlanificados).ceil() : 0;

    // ── Preparar referencias ─────────────────────────────────────
    final presupuestoRef = db.collection('presupuesto_mensual').doc();

    final batch = db.batch();

    // ── Crear documento principal ────────────────────────────────
    batch.set(presupuestoRef, {
      'mes': mes,
      'anio': anio,
      'ahorroAnterior': ahorroAnterior,
      'diasPlanificados': diasPlanificados,
      'etiquetasContables': etiquetasContables,
      'estado': 'abierto',
      'metaDiariaOriginal': metaOriginal,
    });

    // ── Preparar items ───────────────────────────────────────────
    final List<PresupuestoItem> itemsCreados = [];

    for (final item in plantilla) {
      final itemRef = presupuestoRef.collection('items').doc();

      batch.set(itemRef, {
        'nombre': item.nombre,
        'plan': item.planBase,
        'real': 0,
        'orden': item.orden,
      });

      final nuevoItem = PresupuestoItem(
        nombre: item.nombre,
        plan: item.planBase,
        real: 0,
        orden: item.orden,
      );

      nuevoItem.id = itemRef.id;

      itemsCreados.add(nuevoItem);
    }

    // ── Guardar todo en Firestore ─────────────────────────────────
    await batch.commit();

    // ── Construir presupuesto para retornar ──────────────────────
    final presupuesto = PresupuestoMensual(
      mes: mes,
      anio: anio,
      ahorroAnterior: ahorroAnterior,
      diasPlanificados: diasPlanificados,
      etiquetasContables: etiquetasContables,
      estado: 'abierto',
      metaDiariaOriginal: metaOriginal,
      items: itemsCreados,
    );

    presupuesto.id = presupuestoRef.id;

    return presupuesto;
  }

// Actualiza el valor real de un ítem
  Future<void> actualizarRealItem({
    required String presupuestoId,
    required String itemId,
    required String itemNombre,
    required int abonoNuevo, // ← ahora es el ABONO, no el total
    required int realActual,
  }) async {
    final realNuevo = realActual + abonoNuevo;
    final fecha = DateTime.now();
    final fechaStr = '${fecha.day}-${fecha.month}-${fecha.year}';
    final horaStr =
        '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';

    final batch = db.batch();
    // Operación 1 — actualizar real
    final itemRef = db
        .collection('presupuesto_mensual')
        .doc(presupuestoId)
        .collection('items')
        .doc(itemId);
    batch.update(itemRef, {'real': realNuevo});
    // Operación 2 — registrar abono en historial
    final movRef = db
        .collection('presupuesto_mensual')
        .doc(presupuestoId)
        .collection('movimientos')
        .doc(); // ← auto-id
    batch.set(movRef, {
      'fecha': fechaStr,
      'hora': horaStr,
      'itemNombre': itemNombre,
      'valor': abonoNuevo, // ← solo el abono
      'realAnterior': realActual,
      'realNuevo': realNuevo,
      'itemId': itemId,
    });

    await batch.commit(); // ← las dos o ninguna
  }

// Actualiza configuración del presupuesto
  Future<void> actualizarConfigPresupuesto({
    required String presupuestoId,
    required int ahorroAnterior,
    required int diasPlanificados,
    required List<String> etiquetasContables,
  }) async {
    await db.collection('presupuesto_mensual').doc(presupuestoId).update({
      'ahorroAnterior': ahorroAnterior,
      'diasPlanificados': diasPlanificados,
      'etiquetasContables': etiquetasContables,
    });
  }

// Obtiene historial de movimientos del mes
  Future<List<MovimientoPresupuesto>> getMovimientosMes(
      String presupuestoId) async {
    final query = await db
        .collection('presupuesto_mensual')
        .doc(presupuestoId)
        .collection('movimientos')
        .orderBy('fecha', descending: true)
        .get();

    return query.docs.map((e) {
      final mov = MovimientoPresupuesto.fromJson(e.data());
      mov.id = e.id;
      return mov;
    }).toList();
  }

  Future<void> cerrarMes(String presupuestoId, String mes, String anio) async {
    // 1 — Cerrar mes actual
    await db
        .collection('presupuesto_mensual')
        .doc(presupuestoId)
        .update({'estado': 'cerrado'});

    // 2 — Crear mes siguiente desde plantilla
    final mesInt = int.parse(mes);
    final anioInt = int.parse(anio);
    final sigMes = DateTime(anioInt, mesInt + 1);

    await crearPresupuestoDesdePlantilla(
      sigMes.month.toString(),
      sigMes.year.toString(),
    );
  }

  Future<void> eliminarAbono({
    required String presupuestoId,
    required String itemId,
    required String movimientoId,
    required int valorAbono,
    required int realActual,
  }) async {
    final realNuevo = realActual - valorAbono;

    final batch = db.batch();

    // Operación 1 — revertir real
    final itemRef = db
        .collection('presupuesto_mensual')
        .doc(presupuestoId)
        .collection('items')
        .doc(itemId);
    batch.update(itemRef, {'real': realNuevo.clamp(0, realActual)});

    // Operación 2 — eliminar movimiento del historial
    final movRef = db
        .collection('presupuesto_mensual')
        .doc(presupuestoId)
        .collection('movimientos')
        .doc(movimientoId);
    batch.delete(movRef);

    await batch.commit();
  }

  // Agregar en bd_confi.dart
  Future<void> sincronizarItemsConPlantilla(String presupuestoId) async {
    // Obtener plantilla actual
    final plantilla = await getPlantilla();

    // Obtener ítems actuales del presupuesto
    final itemsQuery = await db
        .collection('presupuesto_mensual')
        .doc(presupuestoId)
        .collection('items')
        .get();

    final nombresExistentes =
        itemsQuery.docs.map((e) => e.data()['nombre'] as String).toSet();

    // Agregar solo los que faltan
    final itemsFaltantes =
        plantilla.where((p) => !nombresExistentes.contains(p.nombre)).toList();

    if (itemsFaltantes.isEmpty) return;

    // Batch para agregar todos de una vez
    final batch = db.batch();
    for (final item in itemsFaltantes) {
      final ref = db
          .collection('presupuesto_mensual')
          .doc(presupuestoId)
          .collection('items')
          .doc();
      batch.set(ref, {
        'nombre': item.nombre,
        'plan': item.planBase,
        'real': 0,
        'orden': item.orden,
      });
    }
    await batch.commit();
  }

  Future<void> agregarItemAlMes({
    required String presupuestoId,
    required String nombre,
    required int plan,
    required int orden,
    bool agregarAPlantilla = false,
  }) async {
    final batch = db.batch();

    final itemRef = db
        .collection('presupuesto_mensual')
        .doc(presupuestoId)
        .collection('items')
        .doc();
    batch.set(itemRef, {
      'nombre': nombre,
      'plan': plan,
      'real': 0,
      'orden': orden,
    });

    if (agregarAPlantilla) {
      final plantillaRef = db.collection('plantilla_presupuesto').doc();
      batch.set(plantillaRef, {
        'nombre': nombre,
        'planBase': plan,
        'orden': orden,
      });
    }

    await batch.commit(); // las dos o ninguna
  }

  Future<void> editarPlanItem({
    required String presupuestoId,
    required String itemId,
    required String nombre,
    required int nuevoPlan,
    bool actualizarPlantilla = false,
  }) async {
    final batch = db.batch();

    final itemRef = db
        .collection('presupuesto_mensual')
        .doc(presupuestoId)
        .collection('items')
        .doc(itemId);
    batch.update(itemRef, {'plan': nuevoPlan});

    if (actualizarPlantilla) {
      final q = await db
          .collection('plantilla_presupuesto')
          .where('nombre', isEqualTo: nombre)
          .limit(1)
          .get();
      if (q.docs.isNotEmpty) {
        batch.update(q.docs.first.reference, {'planBase': nuevoPlan});
      }
    }

    await batch.commit();
  }

  Future<void> eliminarItemConAbonos({
    required String presupuestoId,
    required String itemId,
  }) async {
    final base = db.collection('presupuesto_mensual').doc(presupuestoId);

    // Buscar los movimientos de ESE ítem por id
    final movs = await base
        .collection('movimientos')
        .where('itemId', isEqualTo: itemId)
        .get();

    final batch = db.batch();
    for (final doc in movs.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(base.collection('items').doc(itemId));

    await batch.commit(); // movimientos + ítem, o nada
  }

  Future<int> importarItemsDePlantilla(String presupuestoId) async {
    final plantilla = await getPlantilla();

    final actuales = await db
        .collection('presupuesto_mensual')
        .doc(presupuestoId)
        .collection('items')
        .get();
    final nombres =
        actuales.docs.map((e) => e.data()['nombre'] as String).toSet();

    final faltantes =
        plantilla.where((p) => !nombres.contains(p.nombre)).toList();
    if (faltantes.isEmpty) return 0;

    final batch = db.batch();
    for (final item in faltantes) {
      final ref = db
          .collection('presupuesto_mensual')
          .doc(presupuestoId)
          .collection('items')
          .doc();
      batch.set(ref, {
        'nombre': item.nombre,
        'plan': item.planBase,
        'real': 0,
        'orden': item.orden,
      });
    }
    await batch.commit();
    return faltantes.length;
  }
}
