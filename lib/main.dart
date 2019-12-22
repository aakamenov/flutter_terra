import 'package:flutter/material.dart';
import 'package:flutter_terra/models/terrarium.dart';
import 'package:flutter_terra/pages/simulation_page.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider<Terrarium>(
      create: (context) => Terrarium(),
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

