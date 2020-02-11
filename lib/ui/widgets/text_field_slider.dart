import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldSlider extends StatefulWidget {
  final double initialValue;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  TextFieldSlider({this.initialValue = 0.0,
    this.min = 0.0,
    this.max = 1.0,
    @required this.onChanged})
    : assert(initialValue >= min);

  @override
  _TextFieldSliderState createState() => _TextFieldSliderState();
}

class _TextFieldSliderState extends State<TextFieldSlider> {
  TextEditingController _controller;
  double _value;

  @override
  void initState() {
    super.initState();

    _value = widget.initialValue;
    _controller = TextEditingController()..text = _value.toInt().toString();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: <Widget>[
          Slider(
            value: _value,
            min: widget.min,
            max: widget.max,
            onChanged: _sliderChanged
          ),
          Expanded(
            child: TextField(
              textAlign: TextAlign.center,
              inputFormatters: [ TextInputFormatter.withFunction(_validate) ],
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onSubmitted: (value) {
                if(value.isEmpty) {
                  _sliderChanged(widget.min);
                }
              },
              onChanged: _textFieldChanged
            ),
          )
        ],
      )
    );
  }

  _sliderChanged(double value) {
    widget.onChanged(value);

    _controller.text = value.toInt().toString();

    setState(() {
      _value = value;
    });
  }

  _textFieldChanged(String value) {
    final number = double.parse(value);

    widget.onChanged(number);
    
    setState(() {
      _value = number;
    });
  }

  TextEditingValue _validate(TextEditingValue oldValue, TextEditingValue newValue) {
    if(newValue.text.isEmpty)
      return newValue;

    if(newValue.text.contains(' '))
      return oldValue;

    final number = double.tryParse(newValue.text);

    if(number == null ||
      number < widget.min ||
      number > widget.max) {
        return oldValue;
    }

    return newValue;
  }
}
