import 'package:flutter/material.dart';
import 'package:flutter_terra/ui/painters/grid_painter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_terra/models/terrarium.dart';
import 'package:flutter_terra/constants.dart';

class SimulationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final terrarium = Provider.of<Terrarium>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Terra"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).pushNamed(Routes.configurationPage);
            },
          )
        ],
      ),
      body: CustomPaint(
        painter: GridPainter(terrarium),
        child: Center(),
      ),
      bottomNavigationBar: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            RaisedButton(
              color: terrarium.isRunning ? Colors.red : Colors.green,
              child: _buildPlayButtonContent(terrarium.isRunning),
              onPressed: () {
                terrarium.isRunning ? terrarium.stop() : terrarium.start(100);
              },
            ),
            RaisedButton(
              color: Colors.blueGrey,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text("Step"),
                  Icon(Icons.play_arrow)
                ],
              ),
              onPressed: terrarium.isRunning ? null : () {
                 terrarium.step();
              },
            ),
            RaisedButton(
              color: Colors.red,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text("Reset"),
                  const Icon(Icons.autorenew)
                ],
              ),
              onPressed: terrarium.isRunning ? null : () {
                terrarium.buildGrid();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayButtonContent(bool isRunning) {
    if(isRunning) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Text('Stop'),
          const Icon(Icons.stop)
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        const Text('Start'),
        const Icon(Icons.fast_forward)
      ],
    );
  }
}
