import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SimulationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter Terra"),
      ),
      body: Column(
        children: _drawCells(context),
      ),
      bottomNavigationBar: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              color: Colors.deepPurple,
              child: Text("Start"),
              onPressed: () {},
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _drawCells(BuildContext context) {
    final rows = <Widget>[];

    for(int row = 0; row < 60; row++) {
      final cols = <Widget>[];
      
      for(int col = 0; col < 60; col++) {
        cols.add(Expanded(
          child: Container(
              decoration: BoxDecoration(
                  color: row.isEven ? col.isEven ? Colors.black : Colors.white : col.isEven ? Colors.white : Colors.black
              ),
            ),
          ),
        );
      }

      rows.add(Expanded(
          child: Row(
            children: cols,
          ),
        )
      );
    }
    
    return rows;
  }
}
