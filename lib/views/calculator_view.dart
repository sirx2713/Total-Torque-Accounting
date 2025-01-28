import 'package:flutter/material.dart';
import 'dart:math' as math;

class CalculatorView extends StatefulWidget {
  const CalculatorView({super.key});

  @override
  State<CalculatorView> createState() => _CalculatorViewState();
}

class _CalculatorViewState extends State<CalculatorView>
    with SingleTickerProviderStateMixin {
  String _output = '0';
  String _input = '';
  double _num1 = 0;
  String _operand = '';
  bool _newNumber = true;
  late AnimationController _controller;

  final List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onButtonPressed(String buttonText) {
    _controller.forward(from: 0);

    setState(() {
      if (buttonText == 'C') {
        _output = '0';
        _input = '';
        _num1 = 0;
        _operand = '';
        _newNumber = true;
      } else if (buttonText == '⌫') {
        if (_output.length > 1) {
          _output = _output.substring(0, _output.length - 1);
        } else {
          _output = '0';
          _newNumber = true;
        }
      } else if (buttonText == '+/-') {
        if (_output.startsWith('-')) {
          _output = _output.substring(1);
        } else {
          _output = '-$_output';
        }
      } else if (buttonText == '%') {
        double num = double.parse(_output);
        _output = (num / 100).toString();
      } else if (buttonText == '+' ||
          buttonText == '-' ||
          buttonText == '×' ||
          buttonText == '÷') {
        _num1 = double.parse(_output);
        _operand = buttonText;
        _newNumber = true;
        _history.add(_output + ' ' + buttonText);
      } else if (buttonText == '=') {
        double num2 = double.parse(_output);
        _history.add(_output);

        switch (_operand) {
          case '+':
            _output = (_num1 + num2).toString();
            break;
          case '-':
            _output = (_num1 - num2).toString();
            break;
          case '×':
            _output = (_num1 * num2).toString();
            break;
          case '÷':
            _output = (_num1 / num2).toString();
            break;
        }
        _history.add('= $_output');
        _newNumber = true;
      } else {
        if (_newNumber) {
          _output = buttonText;
          _newNumber = false;
        } else {
          _output += buttonText;
        }
      }
    });
  }

  Widget _buildButton(String buttonText, {
    Color? backgroundColor,
    Color? textColor,
    double? fontSize,
  }) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: buttonText == _operand
              ? 1 + _controller.value * 0.1
              : 1 - _controller.value * 0.1,
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: MaterialButton(
          onPressed: () => _onButtonPressed(buttonText),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20),
          color: backgroundColor ?? Colors.white,
          elevation: 2,
          child: Text(
            buttonText,
            style: TextStyle(
              fontSize: fontSize ?? 24,
              color: textColor ?? Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // History View
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.centerRight,
          child: ListView.builder(
            reverse: true,
            scrollDirection: Axis.horizontal,
            itemCount: _history.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Center(
                  child: Text(
                    _history[_history.length - 1 - index],
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Output Display
        Container(
          padding: const EdgeInsets.all(24),
          alignment: Alignment.centerRight,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: _output.length > 10 ? 48 : 64,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            child: Text(_output),
          ),
        ),

        const Divider(thickness: 2),

        // Calculator Buttons
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _buildButton('C',
                        backgroundColor: Colors.red[100],
                        textColor: Colors.red,
                      )),
                      Expanded(child: _buildButton('⌫')),
                      Expanded(child: _buildButton('%')),
                      Expanded(child: _buildButton('÷',
                        backgroundColor: Colors.blue[100],
                        textColor: Colors.blue,
                      )),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _buildButton('7')),
                      Expanded(child: _buildButton('8')),
                      Expanded(child: _buildButton('9')),
                      Expanded(child: _buildButton('×',
                        backgroundColor: Colors.blue[100],
                        textColor: Colors.blue,
                      )),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _buildButton('4')),
                      Expanded(child: _buildButton('5')),
                      Expanded(child: _buildButton('6')),
                      Expanded(child: _buildButton('-',
                        backgroundColor: Colors.blue[100],
                        textColor: Colors.blue,
                      )),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _buildButton('1')),
                      Expanded(child: _buildButton('2')),
                      Expanded(child: _buildButton('3')),
                      Expanded(child: _buildButton('+',
                        backgroundColor: Colors.blue[100],
                        textColor: Colors.blue,
                      )),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _buildButton('+/-')),
                      Expanded(child: _buildButton('0')),
                      Expanded(child: _buildButton('.')),
                      Expanded(child: _buildButton('=',
                        backgroundColor: Colors.blue,
                        textColor: Colors.white,
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
