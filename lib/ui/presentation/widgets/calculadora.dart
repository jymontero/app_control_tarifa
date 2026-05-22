import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

// ── Paleta Dark Premium ───────────────────────────────────────────────────────
class _C {
  static const bg = Color(0xFF0F1923);
  static const cardBg = Color(0xFF1A2535);
  static const cardBorder = Color(0xFF1E2D3D);
  static const accent = Color(0xFFF5C518);
  static const primary = Color(0xFFF1F5F9);
  static const secondary = Color(0xFF94A3B8);
  static const muted = Color(0xFF3D5166);
  static const btnBg = Color(0xFF1A2535);
  static const btnOp = Color(0xFF1E3A55);
  static const red = Color(0xFFF87171);
}

// ignore: must_be_immutable
class Calculadora extends StatefulWidget {
  TextEditingController txtInicial;
  Calculadora(this.txtInicial, {super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CalculadoraState createState() => _CalculadoraState();
}

class _CalculadoraState extends State<Calculadora> {
  final _txtEntrada = TextEditingController(text: '0');
  final _txtResultado = TextEditingController(text: '0');

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    // FIX: sin setState innecesario, sin listeners vacíos
    if (widget.txtInicial.text == '0.0' ||
        widget.txtInicial.text == '# Galones') {
      _txtEntrada.text = '0';
    } else {
      _txtEntrada.text = widget.txtInicial.text;
    }
  }

  @override
  void dispose() {
    // FIX: dispose correcto de los controllers
    _txtEntrada.dispose();
    _txtResultado.dispose();
    super.dispose();
  }

  // ── Lógica ───────────────────────────────────────────────────────────────────

  void _calcular() {
    // FIX: try/catch para expresiones inválidas
    try {
      final Parser p = Parser();
      final ContextModel cm = ContextModel();
      final Expression exp = p.parse(_txtEntrada.text);
      setState(() {
        _txtResultado.text = exp.evaluate(EvaluationType.REAL, cm).toString();
      });
    } catch (e) {
      setState(() {
        _txtResultado.text = 'Error';
      });
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Display entrada
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                decoration: const InputDecoration.collapsed(
                  hintText: '0',
                  hintStyle: TextStyle(
                    fontSize: 36,
                    fontFamily: 'RobotoMono',
                    color: _C.muted,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 36,
                  fontFamily: 'RobotoMono',
                  color: _C.secondary,
                ),
                textAlign: TextAlign.right,
                controller: _txtEntrada,
                onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
              ),
            ),

            // Display resultado
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                decoration: const InputDecoration.collapsed(
                  hintText: 'Resultado',
                  hintStyle: TextStyle(
                    fontFamily: 'RobotoMono',
                    color: _C.muted,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 42,
                  fontFamily: 'RobotoMono',
                  fontWeight: FontWeight.bold,
                  color: _C.primary,
                ),
                textAlign: TextAlign.right,
                controller: _txtResultado,
                readOnly: true,
              ),
            ),

            const SizedBox(height: 12),
            const Divider(color: _C.cardBorder, height: 1),
            const SizedBox(height: 8),

            // Fila 1
            _buildFila([
              _btnAC('AC'),
              _btnBorrar(),
              _btnOp('%'),
              _btnOp('/'),
            ]),

            // Fila 2
            _buildFila([
              _btnNum('7'),
              _btnNum('8'),
              _btnNum('9'),
              _btnOp('*'),
            ]),

            // Fila 3
            _buildFila([
              _btnNum('4'),
              _btnNum('5'),
              _btnNum('6'),
              _btnOp('-'),
            ]),

            // Fila 4
            _buildFila([
              _btnNum('1'),
              _btnNum('2'),
              _btnNum('3'),
              _btnOp('+'),
            ]),

            // Fila 5
            _buildFila([
              _btnNum('0'),
              _btnNum('.'),
              _btnIgual(),
            ]),

            const SizedBox(height: 8),

            // Botones Cancelar / OK
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, _txtEntrada),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _C.cardBorder),
                        ),
                        child: const Center(
                          child: Text(
                            'Cancelar',
                            style: TextStyle(
                              fontSize: 15,
                              color: _C.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (_txtResultado.text == '0' ||
                            _txtResultado.text == 'Error') {
                          Navigator.pop(context, _txtEntrada);
                        } else {
                          Navigator.pop(context, _txtResultado);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: _C.accent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'OK',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF0F1923),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers de layout ─────────────────────────────────────────────────────────

  Widget _buildFila(List<Widget> botones) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: botones,
      ),
    );
  }

  // ── Botones ──────────────────────────────────────────────────────────────────

  // FIX: tipo String explícito en parámetros
  Widget _btnNum(String txt) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: GestureDetector(
          onTap: () {
            setState(() {
              if (_txtEntrada.text == '0') {
                _txtEntrada.text = txt;
              } else {
                _txtEntrada.text += txt;
              }
            });
          },
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: _C.btnBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _C.cardBorder),
            ),
            child: Center(
              child: Text(
                txt,
                style: const TextStyle(
                  fontSize: 22,
                  color: _C.primary,
                  fontFamily: 'RobotoMono',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _btnOp(String txt) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: GestureDetector(
          onTap: () {
            setState(() {
              _txtEntrada.text += txt;
            });
          },
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: _C.btnOp,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _C.accent.withOpacity(0.2)),
            ),
            child: Center(
              child: Text(
                txt,
                style: const TextStyle(
                  fontSize: 22,
                  color: _C.accent,
                  fontFamily: 'RobotoMono',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _btnAC(String txt) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: GestureDetector(
          onTap: () {
            setState(() {
              _txtEntrada.text = '0';
              _txtResultado.text = '0';
            });
          },
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: _C.btnOp,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _C.cardBorder),
            ),
            child: Center(
              child: Text(
                txt,
                style: const TextStyle(
                  fontSize: 20,
                  color: _C.red,
                  fontFamily: 'RobotoMono',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _btnBorrar() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: GestureDetector(
          onTap: () {
            setState(() {
              if (_txtEntrada.text.isNotEmpty) {
                _txtEntrada.text =
                    _txtEntrada.text.substring(0, _txtEntrada.text.length - 1);
                if (_txtEntrada.text.isEmpty) _txtEntrada.text = '0';
              }
            });
          },
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: _C.btnOp,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _C.cardBorder),
            ),
            child: const Center(
              child: Icon(
                Icons.backspace_outlined,
                size: 22,
                color: _C.secondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _btnIgual() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: GestureDetector(
          onTap: _calcular,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: _C.accent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                '=',
                style: TextStyle(
                  fontSize: 26,
                  color: Color(0xFF0F1923),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'RobotoMono',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Constante faltante en _C
extension _CExtension on _C {
  static const red = Color(0xFFF87171);
}
