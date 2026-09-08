import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const CalculadoraApp());
}

class CalculadoraApp extends StatelessWidget {
  const CalculadoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        useMaterial3: true,
      ),
      home: const CalculadoraScreen(),
    );
  }
}

class CalculadoraScreen extends StatefulWidget {
  const CalculadoraScreen({super.key});

  @override
  State<CalculadoraScreen> createState() => _CalculadoraScreenState();
}

class _CalculadoraScreenState extends State<CalculadoraScreen> {
  String _pantalla = '0';
  String _expresion = '';
  double? _valorAnterior;
  String? _operador;
  bool _reiniciarPantalla = false;

  void _presionarBoton(String valor) {
    setState(() {
      switch (valor) {
        case 'C':
          _pantalla = '0';
          _expresion = '';
          _valorAnterior = null;
          _operador = null;
          _reiniciarPantalla = false;
          break;

        case '⌫':
          if (_pantalla.length > 1) {
            _pantalla = _pantalla.substring(0, _pantalla.length - 1);
          } else {
            _pantalla = '0';
          }
          break;

        case '+':
        case '-':
        case '×':
        case '÷':
          _valorAnterior = double.tryParse(_pantalla);
          _operador = valor;
          _expresion = '$_pantalla $valor';
          _reiniciarPantalla = true;
          break;

        case '=':
          if (_valorAnterior != null && _operador != null) {
            final actual = double.tryParse(_pantalla) ?? 0;
            double resultado = 0;
            switch (_operador) {
              case '+':
                resultado = _valorAnterior! + actual;
                break;
              case '-':
                resultado = _valorAnterior! - actual;
                break;
              case '×':
                resultado = _valorAnterior! * actual;
                break;
              case '÷':
                resultado = actual != 0 ? _valorAnterior! / actual : double.nan;
                break;
            }
            _expresion = '$_valorAnterior $_operador $actual =';
            _pantalla = _formatearResultado(resultado);
            _valorAnterior = null;
            _operador = null;
            _reiniciarPantalla = true;
          }
          break;

        case '%':
          final actual = double.tryParse(_pantalla) ?? 0;
          _pantalla = _formatearResultado(actual / 100);
          break;

        case '+/-':
          final actual = double.tryParse(_pantalla) ?? 0;
          _pantalla = _formatearResultado(actual * -1);
          break;

        case '.':
          if (!_pantalla.contains('.')) {
            _pantalla += '.';
          }
          break;

        default: // números 0-9
          if (_pantalla == '0' || _reiniciarPantalla) {
            _pantalla = valor;
            _reiniciarPantalla = false;
          } else {
            _pantalla += valor;
          }
      }
    });
  }

  String _formatearResultado(double valor) {
    if (valor.isNaN) return 'Error';
    if (valor == valor.roundToDouble() && valor.abs() < 1e15) {
      return valor.toInt().toString();
    }
    String texto = valor.toStringAsPrecision(10);
    if (texto.contains('.')) {
      texto = texto.replaceAll(RegExp(r'0+$'), '');
      texto = texto.replaceAll(RegExp(r'\.$'), '');
    }
    return texto;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _expresion,
                      style: const TextStyle(fontSize: 22, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _pantalla,
                        style: const TextStyle(
                          fontSize: 64,
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _construirFila(['C', '⌫', '%', '÷']),
                    _construirFila(['7', '8', '9', '×']),
                    _construirFila(['4', '5', '6', '-']),
                    _construirFila(['1', '2', '3', '+']),
                    _construirFila(['+/-', '0', '.', '=']),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirFila(List<String> botones) {
    return Expanded(
      child: Row(children: botones.map((b) => _construirBoton(b)).toList()),
    );
  }

  Widget _construirBoton(String texto) {
    final esOperador = ['÷', '×', '-', '+', '='].contains(texto);
    final esFuncion = ['C', '⌫', '%', '+/-'].contains(texto);

    Color colorFondo;
    Color colorTexto = Colors.white;

    if (esOperador) {
      colorFondo = texto == '=' ? const Color(0xFF4CAF50) : const Color(0xFFFF9800);
    } else if (esFuncion) {
      colorFondo = const Color(0xFF616161);
    } else {
      colorFondo = const Color(0xFF2C2C2C);
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Material(
          color: colorFondo,
          borderRadius: BorderRadius.circular(40),
          child: InkWell(
            borderRadius: BorderRadius.circular(40),
            onTap: () {
              HapticFeedback.lightImpact();
              _presionarBoton(texto);
            },
            child: Center(
              child: Text(
                texto,
                style: TextStyle(fontSize: 26, color: colorTexto, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ),
    );
  }
}