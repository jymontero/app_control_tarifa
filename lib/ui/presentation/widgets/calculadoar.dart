import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

// ignore: must_be_immutable
class Calculator extends StatefulWidget {
  TextEditingController txtInicial;
  Calculator(this.txtInicial, {super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String strInput = "";
  final txtEntrada = TextEditingController();
  final txtResultado = TextEditingController(text: '0');
  @override
  void initState() {
    super.initState();
    txtEntrada.addListener(() {});
    txtResultado.addListener(() {});
    setState(() {
      if (widget.txtInicial.text == '0.0' ||
          widget.txtInicial.text == '# Galones') {
        txtEntrada.text = "";
      } else {
        txtEntrada.text = widget.txtInicial.text;
      }
    });
  }

  @override
  void dispose() {
    widget.txtInicial.text;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                decoration: const InputDecoration.collapsed(
                    hintText: "0",
                    hintStyle: TextStyle(
                      fontSize: 40,
                      fontFamily: 'RobotoMono',
                    )),
                style: const TextStyle(
                  fontSize: 40,
                  fontFamily: 'RobotoMono',
                ),
                textAlign: TextAlign.right,
                controller: txtEntrada,
                onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
              )),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                decoration: const InputDecoration.collapsed(
                    hintText: "Resultado",
                    fillColor: Colors.deepPurpleAccent,
                    hintStyle: TextStyle(fontFamily: 'RobotoMono')),
                textInputAction: TextInputAction.none,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                    fontSize: 42,
                    fontFamily: 'RobotoMono',
                    fontWeight: FontWeight.bold
                    // color: Colors.deepPurpleAccent
                    ),
                textAlign: TextAlign.right,
                controller: txtResultado,
              )),
          const SizedBox(height: 15.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              btnAC('AC', const Color(0xFFF5F7F9)),
              btnBorrar(),
              boton(
                '%',
                const Color(0xFFF5F7F9),
              ),
              boton(
                '/',
                const Color(0xFFF5F7F9),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              boton('7', Colors.white),
              boton('8', Colors.white),
              boton('9', Colors.white),
              boton(
                '*',
                const Color(0xFFF5F7F9),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              boton('4', Colors.white),
              boton('5', Colors.white),
              boton('6', Colors.white),
              boton(
                '-',
                const Color(0xFFF5F7F9),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              boton('1', Colors.white),
              boton('2', Colors.white),
              boton('3', Colors.white),
              boton('+', const Color(0xFFF5F7F9)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              boton('0', Colors.white),
              boton('.', Colors.white),
              btnIgual(),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.amber),
                      foregroundColor: MaterialStateProperty.all(Colors.black),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)))),
                  onPressed: () {
                    Navigator.pop(context, txtEntrada);
                  },
                  child: const Text('Cancelar ',
                      style: TextStyle(
                        fontSize: 18,
                      ))),
              ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.amber),
                      foregroundColor: MaterialStateProperty.all(Colors.black),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)))),
                  onPressed: () {
                    Navigator.pop(context, txtResultado);
                  },
                  child: const Text('OK',
                      style: TextStyle(
                        fontSize: 18,
                      )))
            ],
          ),
          const SizedBox(
            height: 10.0,
          )
        ],
      ),
    );
  }

  Widget boton(btntxt, Color btnColor) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextButton(
        onPressed: () {
          setState(() {
            txtEntrada.text = txtEntrada.text + btntxt;
          });
        },
        style: TextButton.styleFrom(),
        /*color: btnColor,
        padding: const EdgeInsets.all(18.0),
        splashColor: Colors.black,
        shape: const CircleBorder(),*/
        child: Text(
          btntxt,
          style: const TextStyle(
              fontSize: 28.0, color: Colors.black, fontFamily: 'RobotoMono'),
        ),
      ),
    );
  }

  Widget btnAC(btntext, Color btnColor) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextButton(
        onPressed: () {
          setState(() {
            txtEntrada.text = "";
            txtResultado.text = "";
          });
        },
        /*color: btnColor,
        padding: const EdgeInsets.all(18.0),
        splashColor: Colors.black,
        shape: const CircleBorder(),*/
        child: Text(
          btntext,
          style: const TextStyle(
              fontSize: 28.0, color: Colors.black, fontFamily: 'RobotoMono'),
        ),
      ),
    );
  }

  Widget btnBorrar() {
    return Container(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextButton(
        onPressed: () {
          txtEntrada.text = (txtEntrada.text.isNotEmpty)
              ? (txtEntrada.text.substring(0, txtEntrada.text.length - 1))
              : "";
        },
        /*color: const Color(0xFFF5F7F9),
        padding: const EdgeInsets.all(18.0),
        splashColor: Colors.black,
        shape: const CircleBorder(),*/
        child: const Icon(Icons.backspace, size: 35, color: Colors.blueGrey),
      ),
    );
  }

  Widget btnIgual() {
    return Container(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextButton(
        onPressed: () {
          Parser p = Parser();
          ContextModel cm = ContextModel();
          Expression exp = p.parse(txtEntrada.text);
          setState(() {
            txtResultado.text =
                exp.evaluate(EvaluationType.REAL, cm).toString();
          });
        },
        /*color: Colors.cyan,
        padding: const EdgeInsets.all(18.0),
        splashColor: Colors.black,
        shape: const CircleBorder(),*/
        child: const Text(
          '=',
          style: TextStyle(
              fontSize: 28.0, color: Colors.black, fontFamily: 'RobotoMono'),
        ),
      ),
    );
  }
}
