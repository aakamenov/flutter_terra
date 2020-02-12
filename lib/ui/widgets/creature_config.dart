import 'package:flutter/material.dart';
import 'package:flutter_terra/models/terrarium.dart';
import 'package:flutter_terra/ui/widgets/numeric_text_field.dart';
import 'package:flutter_terra/ui/widgets/text_field_slider.dart';

class CreatureConfig extends StatelessWidget {
  final Creature _creature;

  CreatureConfig(this._creature);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ListView(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(_creature.type, textScaleFactor: 2.0),
              IconButton(icon: Icon(Icons.edit), onPressed: () {})
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Initial energy:'),
              TextFieldSlider(
                initialValue: _creature.initialEnergy.toDouble(),
                min: 1,
                max: Creature.maxEnergy.toDouble(),
                onChanged: (value) {
                  _creature.initialEnergy = value.toInt();
                }
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Efficiency (%):'),
              TextFieldSlider(
                initialValue: _creature.efficiency * 100,
                min: 1,
                max: 100,
                onChanged: (value) {
                  _creature.efficiency = value / 100;
                }
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Size:'),
              NumericTextField<int>(
                initialValue: _creature.size,
                min: 1,
                max: 1000,
                onChanged: (value) {
                  _creature.size = value;
                }
              ),
            ],
          )
        ],
      ),
    );
  }
}
