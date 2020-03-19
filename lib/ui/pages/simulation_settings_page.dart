import 'package:flutter/material.dart';
import 'package:flutter_terra/styles.dart';
import 'package:provider/provider.dart';
import 'package:flutter_terra/models/terrarium.dart';
import 'package:flutter_terra/ui/widgets/distribution_slider.dart';

class SimulationSettingsPage extends StatefulWidget {
  @override
  _SimulationSettingsPageState createState() => _SimulationSettingsPageState();
}

class _SimulationSettingsPageState extends State<SimulationSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final terrarium = Provider.of<Terrarium>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Simulation Settings"),
      ),
      body: Padding(
        padding: pagePadding,
        child: Column(
          children: <Widget>[
            Center(
              child: const Text(
                "Distribution",
                style: bigText,
              )
            ),
            SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Consumer<SimulationSettings>(
                    builder: (context, settings, widget) {
                      final data = Map<String, DistributionSliderValueData>();

                      for (var entry in settings.distribution.entries) {
                        data[entry.key] = DistributionSliderValueData(
                          color: terrarium.getCreature(entry.key).color,
                          value: entry.value * 0.01);
                      }

                      return DistributionSlider<String>(
                        values: data,
                        onChanged: (key, value) {
                          settings.distribution[key] = (value * 100).toInt();
                        },
                      );
                    },
                  )
                ],
              ),
            ),
          ]
        ),
      )
    );
  }
}
