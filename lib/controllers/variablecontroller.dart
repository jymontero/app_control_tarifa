class VariableContoller {
  late List listafromBD = [];

  VariableContoller();

  get listaControllerVariable => listafromBD;

  set setlistaBD(List lista) {
    listafromBD = lista;
  }

  /*void sumarListaBd(List lista) {
    listafromBD = lista;

    int sumar = 0;
    for (var item in listafromBD) {
      int aux = item["valor"];
      sumar += aux;
    }
  }*/
}
