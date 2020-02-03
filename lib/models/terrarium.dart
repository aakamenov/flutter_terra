library terrarium;

import 'dart:collection';
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';

part 'creature.dart';

class Cell {
  final Point position;
  Creature creature;

  bool get isFree => creature == null || creature.isDead;
  Color get color => creature?.value;

  Cell(this.position, this.creature);
}

class Terrarium extends ChangeNotifier {
  static final gridHeight = 60;
  static final gridWidth = 60;

  bool get isRunning => _isRunning;
  bool _isRunning = false;

  final List<List<Cell>> _grid = List(gridWidth);
  HashMap<String, Creature> _registeredCreatures = HashMap();
  Timer _timer;

  start(int ms) {
    _isRunning = true;
    _timer = Timer.periodic(Duration(milliseconds: ms), (timer) => _step());
  }

  stop() {
    _isRunning = false;
    _timer.cancel();
    notifyListeners();
  }

  Color colorAt(int x, int y) {
    if(x >= _grid.length) {
      return Color.fromRGBO(0, 0, 0, 0.0);
    }

    if(y >= _grid[x].length) {
      return Color.fromRGBO(0, 0, 0, 0.0);
    }

    return _grid[x][y].color;
  }

  bool registerCreature(Creature creature) {
    if(_registeredCreatures.containsKey(creature.type)) {
      return false;
    }

    _registeredCreatures[creature.type] = creature;

    return true;
  }

  buildGrid(Map<String, int> distribution) {
    final rand = Random();
    int totalWeight = distribution.values.fold(0, (currentVal, next) { return currentVal += next; });
    
    final pickRandomCreature = () {
      var randNum = rand.nextInt(totalWeight);

      for(var key in distribution.keys) {
        final weight = distribution[key];

        if(randNum < weight)
          return key;

        randNum -= weight;
      }

      return distribution.keys.first; //Shouldn't get to here.
    };

    for(int x = 0; x < gridWidth; x++) {
      _grid[x] = List(gridHeight);
      
      for(int y = 0; y < gridHeight; y++) {
        _grid[x][y] = Cell(Point(x, y), Creature.clone(_registeredCreatures[pickRandomCreature()]));
      }
    }

    notifyListeners();
  }

  _step() {
    var hasChanged = false;

    for(int x = 0; x < gridWidth; x++) {
      for(int y = 0; y < gridHeight; y++) {
        final cell = _grid[x][y];

        if(cell.isFree) {
          //Remove the creature if it's dead
          cell.creature = null;
          continue;
        }

        final result = cell.creature.process(_getNeighbors(cell));
        final point = result.point;

        if(result.action != ProcessAction.none)
          hasChanged = true;

        switch(result.action) {
          case ProcessAction.move:
            cell.creature._energy -= 10;

            //Move the creature
            _grid[point.x][point.y].creature = cell.creature;
            cell.creature = null;
            break;
          case ProcessAction.reproduce:
            //Lose energy equal to the child's initial energy
            cell.creature._energy -= cell.creature.initialEnergy;

            _grid[point.x][point.y].creature = Creature.clone(cell.creature);
            break;
          case ProcessAction.eat:
            final eatenCreature = _grid[point.x][point.y].creature;
            cell.creature._energy += (eatenCreature.energy * cell.creature.efficiency).round();

            //Move the creature
            _grid[point.x][point.y].creature = cell.creature;
            cell.creature = null;
            break;
          case ProcessAction.none:
            cell.creature.wait();
            break;
        }
      }
    }

    if(!hasChanged)
      stop();
    
    notifyListeners();
  }

  List<Cell> _getNeighbors(Cell cell) {
    var neighbors = <Cell>[];

    final radius = cell.creature.actionRadius;
    final pos = cell.position;

    final xLo = max(0, pos.x - radius);
    final yLo = max(0, pos.y - radius);
    final xHi = min(pos.x + radius, gridWidth - 1);
    final yHi = min(pos.y + radius, gridHeight - 1);

    for (var x = xLo; x <= xHi; ++x) {
      for (var y = yLo; y <= yHi; ++y) {
        if (x != pos.x || y != pos.y) {
          neighbors.add(_grid[x][y]);
        }
      }
    }

    return neighbors;
  }
}
