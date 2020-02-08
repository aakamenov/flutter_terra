import 'package:flutter/material.dart';
import 'package:flutter_terra/ui/painters/grid_painter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_terra/models/terrarium.dart';
import 'dart:collection';

class SimulationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final terrarium = Provider.of<Terrarium>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter Terra"),
      ),
      body: CustomPaint(
        painter: GridPainter(terrarium),
        child: Center(),
      ),
      bottomNavigationBar: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            FlatButton(
              color: Colors.deepPurple,
              child: terrarium.isRunning ? Text("Stop") : Text("Start"),
              onPressed: () {
                terrarium.isRunning ? terrarium.stop() : terrarium.start(2000);
              },
            ),
            FlatButton(
              color: Colors.deepPurple,
              child: Text("Step"),
              onPressed: () {
                terrarium.step();
              },
            ),
            FlatButton(
              color: Colors.deepPurple,
              child: Text("Reset"),
              onPressed: () {
                final distribution = HashMap<String, int>();
                distribution['brute'] = 20;
                distribution['bully'] = 20;

                terrarium.buildGrid(distribution);
              },
            ),
          ],
        ),
      ),
    );
  }
}
