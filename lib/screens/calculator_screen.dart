import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import '../database/database.dart';
import '../model/calcul.dart';

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = '';
  String _result = '0';
  List<String> _history = [];
  bool _justCalculated = false; // 👈 Ajout

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _expression = '';
        _result = '0';
        _justCalculated = false;
      } else if (value == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else if (value == '=') {
        _calculateResult();
      } else if (value == '+/-') {
        _toggleSign();
      } else if (value == '%') {
        _calculatePercentage();
      } else {
        // 🔥 IMPORTANT : si on tape un chiffre juste après "=", on recommence
        if (_justCalculated && RegExp(r'\d').hasMatch(value)) {
          _expression = '';
          _result = '0';
        }

        _expression += value;
        _justCalculated = false;
      }
    });
  }

  void _toggleSign() {
    if (_result != '0' && _result != 'Erreur') {
      double num = double.parse(_result);
      _result = (num * -1).toString();
    }
  }

  void _calculatePercentage() {
    if (_result != '0' && _result != 'Erreur') {
      double num = double.parse(_result);
      _result = (num / 100).toString();
    }
  }

  void _calculateResult() {
    try {
      String exp = _expression
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll(',', '.');

      Parser p = Parser();
      Expression expression = p.parse(exp);
      ContextModel cm = ContextModel();
      double eval = expression.evaluate(EvaluationType.REAL, cm);

      _result = eval.toString();
      if (_result.endsWith('.0')) {
        _result = _result.substring(0, _result.length - 2);
      }

      // Historique visuel
      String historyEntry = '$_expression=$_result';
      _history.insert(0, historyEntry);
      if (_history.length > 10) _history = _history.sublist(0, 10);

      // Enregistrement BDD
      final calc = Calculation(
        expression: _expression,
        result: _result,
        timestamp: DateTime.now().toIso8601String(),
      );
      DatabaseHelper.instance.insertCalculation(calc);

      _justCalculated = true; // ✔️ Utilisé pour détecter un nouveau calcul
    } catch (e) {
      _result = 'Erreur';
    }
  }

  void _clearHistory() async {
    setState(() {
      _history.clear();
    });
    await DatabaseHelper.instance.clearHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Zone d'affichage avec historique
            Expanded(
              child: SingleChildScrollView(
                reverse: true,
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ..._history.map((h) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        h,
                        style: TextStyle(color: Colors.grey[600], fontSize: 20),
                      ),
                    )),
                    SizedBox(height: 10),
                    Text(
                      _expression.isEmpty ? '' : _expression,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: 10),
                    Text(
                      _result,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 70,
                        fontWeight: FontWeight.w200,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ),

            _buildButtonGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonGrid() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          _buildButtonRow(['C', '+/-', '%', '⌫'], [0, 0, 0, 3]),
          SizedBox(height: 10),
          _buildButtonRow(['7', '8', '9', '🗑️'], [1, 1, 1, 3]),
          SizedBox(height: 10),
          _buildButtonRow(['4', '5', '6', '×'], [1, 1, 1, 2]),
          SizedBox(height: 10),
          _buildButtonRow(['1', '2', '3', '-'], [1, 1, 1, 2]),
          SizedBox(height: 10),
          _buildButtonRow(['0', '.', '+', '='], [1, 1, 2, 2]),
        ],
      ),
    );
  }

  Widget _buildButtonRow(List<String> buttons, List<int> types) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: buttons.asMap().entries.map((entry) {
        return _buildButton(entry.value, types[entry.key]);
      }).toList(),
    );
  }

  Widget _buildButton(String text, int type) {
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (type) {
      case 0:
        backgroundColor = Color(0xFF505050);
        break;
      case 1:
        backgroundColor = Colors.white;
        textColor = Colors.black;
        break;
      case 2:
        backgroundColor = Color(0xFFFF9F0A);
        break;
      case 3:
        backgroundColor = Color(0xFF505050);
        break;
      default:
        backgroundColor = Color(0xFF333333);
    }

    return Container(
      width: 80,
      height: 80,
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: ElevatedButton(
        onPressed: () {
          if (text == '🗑️') {
            _clearHistory();
          } else {
            _onButtonPressed(text);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: CircleBorder(),
          padding: EdgeInsets.zero,
        ),
        child: text == '⌫'
            ? Icon(Icons.backspace_outlined, color: Colors.white, size: 28)
            : text == '🗑️'
            ? Icon(Icons.delete, color: Colors.white, size: 28)
            : Text(
          text,
          style: TextStyle(fontSize: 32, color: textColor, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }
}
