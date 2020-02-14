import 'dart:math';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_terra/models/terrarium.dart';
import 'package:flutter_terra/ui/widgets/numeric_text_field.dart';
import 'package:flutter_terra/ui/widgets/text_field_slider.dart';
import 'package:provider/provider.dart';

class CreatureConfig extends StatefulWidget {
  final Creature _creature;

  CreatureConfig(this._creature);

  @override
  _CreatureConfigState createState() => _CreatureConfigState();
}

class _CreatureConfigState extends State<CreatureConfig> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        final distribution = HashMap<String, int>();
        distribution['brute'] = 20;
        distribution['bully'] = 20;
        Provider.of<Terrarium>(context).buildGrid(distribution);
        return Future.value(true);
      },
      child: SingleChildScrollView(
        child: Container(
          height: 1000,
          padding: const EdgeInsets.all(12.0),
          child: ListView(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(widget._creature.type, textScaleFactor: 2.0),
                  IconButton(icon: Icon(Icons.edit), onPressed: () {})
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const Text('Color:'),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(left: 10),
                      child: RaisedButton(
                        onPressed: () async {
                          await _displayColorPicker(context);
                          setState(() {});
                        },
                        color: widget._creature.color,
                      ),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('Initial energy:'),
                  TextFieldSlider(
                    initialValue: widget._creature.initialEnergy.toDouble(),
                    min: 1,
                    max: Creature.maxEnergy.toDouble(),
                    onChanged: (value) {
                      widget._creature.initialEnergy = value.toInt();
                    }
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('Efficiency (%):'),
                  TextFieldSlider(
                    initialValue: widget._creature.efficiency * 100,
                    min: 1,
                    max: 100,
                    onChanged: (value) {
                      widget._creature.efficiency = value / 100;
                    }
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('Size:'),
                  NumericTextField<int>(
                    initialValue: widget._creature.size,
                    min: 1,
                    max: 1000,
                    onChanged: (value) {
                      widget._creature.size = value;
                    }
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('Action radius:'),
                  TextFieldSlider(
                    initialValue: widget._creature.actionRadius.toDouble(),
                    min: 1,
                    max: max(Terrarium.gridHeight, Terrarium.gridWidth).toDouble(),
                    onChanged: (value) {
                      widget._creature.actionRadius = value.toInt();
                    }
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('Sustainability:'),
                  TextFieldSlider(
                    initialValue: widget._creature.sustainability.toDouble(),
                    min: 1,
                    max: (Terrarium.gridHeight * Terrarium.gridWidth).toDouble(),
                    onChanged: (value) {
                      widget._creature.sustainability = value.toInt();
                    }
                  )
                ]
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('Reproducibility (%):'),
                  TextFieldSlider(
                    initialValue: widget._creature.reproduceLevel * 100,
                    min: 0,
                    max: 100,
                    onChanged: (value) {
                      widget._creature.reproduceLevel = value / 100;
                    }
                  )
                ]
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('Move level (%):'),
                  TextFieldSlider(
                    initialValue: widget._creature.moveLevel * 100,
                    min: 0,
                    max: 100,
                    onChanged: (value) {
                      widget._creature.moveLevel = value / 100;
                    }
                  )
                ]
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _displayColorPicker(BuildContext context) async {
    return showDialog(
      context: context,
      child: AlertDialog(
        content: SingleChildScrollView(
          child: ColorPicker(
            enableAlpha: false,
            enableLabel: true,
            displayThumbColor: false,
            pickerAreaHeightPercent: 1.0,
            colorPickerWidth: 280.0,
            pickerColor: widget._creature.color,
            onColorChanged: (value) {
              widget._creature.color = value;
            },
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
