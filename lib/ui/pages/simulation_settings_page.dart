import 'package:flutter/material.dart';
import 'package:flutter_terra/styles.dart';
import 'package:flutter_terra/ui/widgets/help_text.dart';
import 'package:flutter_terra/ui/widgets/text_field_slider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_terra/models/terrarium.dart';
import 'package:flutter_terra/ui/widgets/distribution_slider.dart';

class SimulationSettingsPage extends StatelessWidget {
@override
  Widget build(BuildContext context) {
    final terrarium = Provider.of<Terrarium>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Simulation Settings"),
      ),
      body: Padding(
        padding: pagePadding,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Center(
                child: const HelpText(
                  text: "Speed (ms)",
                  helpText: "Controls the speed of the simulation in automatic mode (when pressing the 'Start' button).",
                  textStyle: bigText,
                )
              ),
              TextFieldSlider(
                initialValue: terrarium.settings.simulationSpeed.toDouble(),
                min: SimulationSettings.minSpeed.toDouble(),
                max: SimulationSettings.maxSpeed.toDouble(),
                onChanged: (value) {
                  terrarium.settings.simulationSpeed = value.toInt();
                },
              ),
              Center(
                child: const HelpText(
                  text: "Distribution",
                  helpText: "Controls the percentage of the grid that each creature type occupies. The striped red lines indicate emptiness.",
                  textStyle: bigText,
                )
              ),
              _buildDistributionSlider(terrarium),
            ],
          ),
        ),       
      ),   
    );
  }

  Widget _buildDistributionSlider(Terrarium terrarium) {
    final data = Map<String, DistributionSliderValueData>();

    for (var entry in terrarium.settings.distribution.entries) {
      data[entry.key] = DistributionSliderValueData(
        color: terrarium.getCreature(entry.key).color,
        value: entry.value * 0.01);
    }

    return DistributionSlider<String>(
      values: data,
      onChanged: (key, value) {
        terrarium.settings.distribution[key] = (value * 100).toInt();
      },
    );
  }
}
