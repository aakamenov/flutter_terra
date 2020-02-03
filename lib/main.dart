import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_terra/models/terrarium.dart';
import 'package:flutter_terra/pages/simulation_page.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Terrarium>(
      create: (context) {
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

        final distribution = HashMap<String, int>();
        distribution['brute'] = 20;
        distribution['bully'] = 20;

        terrarium.buildGrid(distribution);

        return terrarium; 
      },
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.indigo,
        ),
        routes: {
          "/": (context) => SimulationPage()
        },
      ),
    );
  }
}

