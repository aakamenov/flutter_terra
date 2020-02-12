import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumericTextField<T extends num> extends StatefulWidget {
  final ValueChanged<T> onChanged;
  final T initialValue;
  final T min;
  final T max;

  NumericTextField({ this.onChanged, this.initialValue, @required this.min, @required this.max }) : 
    assert(min != null),
    assert(max != null),
    assert(min < max),
    assert(initialValue >= min && initialValue <= max);

  @override
  _NumericTextFieldState<T> createState() => _NumericTextFieldState<T>();
}

class _NumericTextFieldState<T extends num> extends State<NumericTextField<T>> {
  TextEditingController controller;
  Timer timer;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController()..text = validateMinMax(widget.initialValue).toString();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: <Widget>[
          buildButton(false),
          Expanded(
            child: TextField(
              textAlign: TextAlign.center,
              inputFormatters: [ TextInputFormatter.withFunction(validateTextInput) ],
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onSubmitted: widget.onChanged == null ? null : (value) {
                if(value.isEmpty || value == '-') {
                  controller.text = widget.min.toString();
                  widget.onChanged(widget.min);
                } else {
                  widget.onChanged(validateMinMax(num.tryParse(value)));
                }
              },
              onChanged: widget.onChanged == null ? null : (value) {
                if(value.isNotEmpty)
                  widget.onChanged(validateMinMax(num.tryParse(value)));
              }
            ),
          ),
          buildButton(true)
        ],
      ),
    );
  }

  Widget buildButton(bool isIncrement) {
    return GestureDetector(
      child: ButtonTheme(
        shape: CircleBorder(),
        minWidth: 20,
        height: 20,
        child: RaisedButton(
          padding: EdgeInsets.all(0.0),
          child: isIncrement ? Icon(Icons.add) : Icon(Icons.remove),
          onPressed: isIncrement ? increment : decrement
        ),
      ),
      onLongPress: () {
        timer = Timer.periodic(
          Duration(milliseconds: 50), 
          isIncrement ? (timer) { increment(); } : (timer) { decrement(); }
        );
      },
      onLongPressUp: () {
        if(timer != null)
          timer.cancel();
      },
    );
  }

  TextEditingValue validateTextInput(TextEditingValue oldValue, TextEditingValue newValue) {
    //Allow the user to delete the entire text
    //Leaving the field with an empty text is handled by the "onSubmitted" handler
    if(newValue.text.isEmpty)
      return newValue;

    //Allow the user to type in a negative number
    if(newValue.text == '-')
      return newValue;

    //Dont allow numbers to start with zeroes - doesn't break anything but looks awkward
    if(newValue.text.startsWith('0') && newValue.text.length > 1)
      return oldValue;
    
    if(newValue.text.contains(' '))
      return oldValue;

    //Disallow decimal numbers when the field is for integers only
    if(widget is NumericTextField<int> && newValue.text.endsWith('.')) {
      return oldValue;
    }
    
    if(num.tryParse(newValue.text) == null) 
        return oldValue;

    return newValue;
  }

  increment() {
    final increment = num.parse(controller.text) + 1;
    controller.text = increment.toString();

    widget.onChanged(validateMinMax(increment));
  }

  decrement() {
    final decrement = num.parse(controller.text) - 1;
    controller.text = decrement.toString();

    widget.onChanged(validateMinMax(decrement));
  }

  T validateMinMax(T value) {
    if(value == null)
      return null;

    if(widget.min > value) {
      controller.text = widget.min.toString();
      controller.selection = TextSelection.collapsed(offset: controller.text.length);
      return widget.min;
    }

    if(widget.max < value) {
      controller.text = widget.max.toString();
      controller.selection = TextSelection.collapsed(offset: controller.text.length);
      return widget.max;
    }

    return value;
  }
}
