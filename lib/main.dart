import 'package:flutter/material.dart';
import 'package:flutter_terra/models/terrarium.dart';
import 'package:flutter_terra/ui/pages/configuration_page.dart';
import 'package:flutter_terra/ui/pages/simulation_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_terra/constants.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final terrarium = Terrarium();

    terrarium.registerCreature(Creature(
        type: 'brute',
        color: Color.fromRGBO(0, 255, 255, 1.0),
        initialEnergy: 10,
        size: 20
      )
    );
    terrarium.registerCreature(Creature(
        type: 'bully',
        color: Color.fromRGBO(241, 196, 15, 1.0),
        initialEnergy: 20,
        reproduceLevel: 0.6,
        sustainability: 3
      )
    );

    terrarium.settings.distribution['brute'] = 20;
    terrarium.settings.distribution['bully'] = 20;

    terrarium.buildGrid();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: terrarium),
        ChangeNotifierProvider.value(value:terrarium.settings)
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.deepOrange
        ),
        routes: {
          Routes.simulationPage: (context) => SimulationPage(),
          Routes.configurationPage: (context) => ConfigurationPage()
        },
      ),
    );
  }
}

