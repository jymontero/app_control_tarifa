import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:taxi_servicios/domain/entitis/servicio.dart';
import 'package:taxi_servicios/domain/entitis/variables.dart';

class FireStoreDataBase {
  FirebaseFirestore db = FirebaseFirestore.instance;
  final List _listaVariablesBD = [];
  final int _metaConfigurada = 0;

  List get listaVariablesConfiguracion => _listaVariablesBD;
  int get metaConfigurada => _metaConfigurada;

/* ignore: slash_for_doc_comments
 CONSULTAS  READ BASE DE DATOS 
 */

  Future<List<Variable>> getModeloVariables() async {
    final querySnapshot = await db.collection('variables').get();
    final variables = querySnapshot.docs.map((e) {
      final model = Variable.fromJson(e.data());
      model.id = e.id;
      return model;
    }).toList();
    return variables;
  }

  Future<List<Servicio>> getModeloServicios(String fecha) async {
    final queryGanancias =
        await db.collection('servicios').where('fecha', isEqualTo: fecha).get();

    final servicios = queryGanancias.docs.map((e) {
      final modeloServicio = Servicio.fromJson(e.data());
      modeloServicio.id = e.id;
      return modeloServicio;
    }).toList();
    return servicios;
  }

  Future<List> getGanancias(String mes) async {
    late List listaGanancias = [];

    try {
      Query<Map<String, dynamic>> cfGanancias =
          db.collection('ingresos').where('mes', isEqualTo: mes);
      //  .orderBy('dia', descending: false);

      QuerySnapshot queryGanancias = await cfGanancias.get();

      /*final gananciaRef = db.collection('ingresos');
      gananciaRef.where('mes', isEqualTo: mes).orderBy('dia', descending: true);*/
      print('**********************');

      for (var item in queryGanancias.docs) {
        listaGanancias.add(item.data());
      }
    } catch (e) {
      debugPrint('Eror -$e');
    }
    return listaGanancias;
  }

  Future<List> getVariables() async {
    late List listaVariables = [];

    try {
      CollectionReference cfVariables = db.collection('variables');
      DocumentReference documentReference = db.collection('variables').doc();

      documentReference.get().then((datasnapshot) {
        datasnapshot.data();
      });

      QuerySnapshot queryVariables = await cfVariables.get();

      for (var item in queryVariables.docs) {
        listaVariables.add(item.data());
      }
    } catch (e) {
      debugPrint("Error - $e");
    }

    return listaVariables;
  }

//Metodos agregar datos a la base de datos FIREBASE
  Future<void> addVariableBD(int monto, String nombre) async {
    Map<String, dynamic> variable = {"valor": monto, "nombre": nombre};
    await db.collection('variables').doc().set(variable);
  }

  Future<void> addServicioBD(String fecha, String hora, int valor) async {
    Map<String, dynamic> servicio = {
      "fecha": fecha,
      "hora": hora,
      "valor": valor,
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
    return "Eliminardoo....***";
  }

  Future<String> eliminarVariable(String id) async {
    await db.collection('variables').doc(id).delete();
    return "Eliminardoo....***";
  }
}
