import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_terra/models/terrarium.dart';
import 'package:flutter_terra/ui/widgets/numeric_text_field.dart';
import 'package:flutter_terra/ui/widgets/text_field_slider.dart';

class CreatureConfig extends StatefulWidget {
  final Creature _creature;

  CreatureConfig(this._creature);

  @override
  _CreatureConfigState createState() => _CreatureConfigState();
}

class _CreatureConfigState extends State<CreatureConfig> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 1000,
      padding: const EdgeInsets.all(12.0),
      child: ListView(
        children: <Widget>[
          Center(
            heightFactor: 1.5,
            child: Text(widget._creature.type, textScaleFactor: 2.0)
          ),
          buildSettingRow(
            description: const Text('Color'),
            child:Container(
              padding: EdgeInsets.only(left: 10),
              child: RaisedButton(
                onPressed: () async {
                  await displayColorPicker(context);
                  setState(() {});
                },
                color: widget._creature.color,
              ),
            )
          ),
          buildSettingRow(
            description: const Text('Size'),
            child: NumericTextField<int>(
              initialValue: widget._creature.size,
              min: 1,
              max: 1000,
              onChanged: (value) {
                widget._creature.size = value;
              }
            )
          ),
          buildSettingRow(
            description: const Text('Maximum energy'),
            child: TextFieldSlider(
              initialValue: widget._creature.maxEnergy.toDouble(),
              min: 1,
              max: 1000,
              onChanged: (value) {
                //Rebuild because other values depend on that
                setState(() {
                  widget._creature.maxEnergy = value.toInt();
                });
              },
            )
          ),
          buildSettingRow(
            description: const Text('Initial energy'),
            child: TextFieldSlider(
              key: UniqueKey(),
              initialValue: widget._creature.initialEnergy.toDouble(),
              min: 1,
              max: widget._creature.maxEnergy.toDouble(),
              onChanged: (value) {
                widget._creature.initialEnergy = value.toInt();
              }
            )
          ),
          buildSettingRow(
            descriptionFlex: 3,
            childFlex: 1,
            description: const Text("Gains energy when idle"),
            child: Switch(
              activeColor: theme.buttonColor,
              value: widget._creature.gainEnergyOnWait,
              onChanged: (value) {
                setState(() {
                  widget._creature.gainEnergyOnWait = value;
                });
              },
            )
          ),
          buildSettingRow(
            description: widget._creature.gainEnergyOnWait ? const Text("Energy gain when idle") : const Text("Energy loss when idle"),
            child: TextFieldSlider(
              key: UniqueKey(),
              min: 0,
              max: widget._creature.maxEnergy.toDouble(),
              initialValue: widget._creature.waitEnergyModifier.toDouble(),
              onChanged: (value) {
                widget._creature.waitEnergyModifier = value.toInt();
              },
            )
          ),
          buildSettingRow(
            description: const Text('Efficiency (%)'),
            child: TextFieldSlider(
              initialValue: widget._creature.efficiency * 100,
              min: 1,
              max: 100,
              onChanged: (value) {
                widget._creature.efficiency = value / 100;
              }
            )
          ),
          buildSettingRow(
            description: const Text('Action radius'),
            child: TextFieldSlider(
              initialValue: widget._creature.actionRadius.toDouble(),
              min: 1,
              max: max(Terrarium.gridHeight, Terrarium.gridWidth).toDouble(),
              onChanged: (value) {
                widget._creature.actionRadius = value.toInt();
              }
            )
          ),
          buildSettingRow(
            description: const Text('Sustainability'),
            child: TextFieldSlider(
              initialValue: widget._creature.sustainability.toDouble(),
              min: 1,
              max: (Terrarium.gridHeight * Terrarium.gridWidth).toDouble() - 1,
              onChanged: (value) {
                widget._creature.sustainability = value.toInt();
              }
            )
          ),
          buildSettingRow(
            description: const Text('Reproducibility (%)'),
            child: TextFieldSlider(
              initialValue: widget._creature.reproduceLevel * 100,
              min: 0,
              max: 100,
              onChanged: (value) {
                widget._creature.reproduceLevel = value / 100;
              }
            )
          ),
          buildSettingRow(
            description: const Text('Move level (%)'),
            child: TextFieldSlider(
              initialValue: widget._creature.moveLevel * 100,
              min: 0,
              max: 100,
              onChanged: (value) {
                widget._creature.moveLevel = value / 100;
              }
            )
          )
        ],
      ),
    );
  }

  Widget buildSettingRow({ 
      Text description,
      Widget child,
      int descriptionFlex = 1,
      int childFlex = 3
    }) {
    return Flex(
      direction: Axis.horizontal,
      children: <Widget>[
        Expanded(flex: descriptionFlex, child: description),
        Expanded(
          flex: childFlex,
          child: child,
        )
      ],
    );
  }

  Future<void> displayColorPicker(BuildContext context) async {
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
