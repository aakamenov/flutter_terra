import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldSlider extends StatefulWidget {
  final double initialValue;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final int sliderFlex;
  final int textFieldFlex;

  TextFieldSlider({ Key key,
    this.initialValue = 0.0,
    this.min = 0.0,
    this.max = 1.0,
    this.sliderFlex = 4,
    this.textFieldFlex = 1,
    @required this.onChanged})
    : assert(initialValue >= min),
      assert(sliderFlex >= 1),
      assert(textFieldFlex >= 1),
      super(key: key);

  @override
  _TextFieldSliderState createState() => _TextFieldSliderState();
}

class _TextFieldSliderState extends State<TextFieldSlider> {
  TextEditingController controller;
  double sliderValue;

  @override
  void initState() {
    super.initState();

    sliderValue = widget.initialValue;
    controller = TextEditingController()..text = sliderValue.toInt().toString();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Flex(
      mainAxisAlignment: MainAxisAlignment.center,
      direction: Axis.horizontal,
      children: <Widget>[
        Expanded(
          flex: widget.sliderFlex,
          child: Slider(
            value: sliderValue,
            min: widget.min,
            max: widget.max,
            onChanged: sliderChanged
          ),
        ),
        Expanded(
          flex: widget.textFieldFlex,
          child: TextField(
            textAlign: TextAlign.center,
            inputFormatters: [ TextInputFormatter.withFunction(validate) ],
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onSubmitted: (value) {
              if(value.isEmpty) {
                sliderChanged(widget.min);
              }
            },
            onChanged: textFieldChanged
          ),
        )
      ],
    );
  }

  sliderChanged(double value) {
    widget.onChanged(value);

    controller.text = value.toInt().toString();

    setState(() {
      sliderValue = value;
    });
  }

  textFieldChanged(String value) {
    final number = double.parse(value);

    widget.onChanged(number);
    
    setState(() {
      sliderValue = number;
    });
  }

  TextEditingValue validate(TextEditingValue oldValue, TextEditingValue newValue) {
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
