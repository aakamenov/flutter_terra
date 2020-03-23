library terrarium;

import 'dart:math';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

part 'creature.dart';
part 'simulation_settings.dart';

class Cell {
  final Point position;
  Creature creature;

  bool get isFree => creature == null || creature.isDead;
  Color get color => creature?.color;

  Cell(this.position, this.creature);
}

class Terrarium extends ChangeNotifier {
  static final gridHeight = 40;
  static final gridWidth = 40;

  bool get isRunning => _isRunning;
  bool _isRunning = false;

  Iterable<Creature> get registeredCreatures => _registeredCreatures.values;

  final List<List<Cell>> _grid = List(gridWidth);
  final Map<String, Creature> _registeredCreatures = Map();
  final SimulationSettings settings = SimulationSettings();
  Timer _timer;

  void start() {
    _isRunning = true;
    _timer = Timer.periodic(Duration(milliseconds: settings.simulationSpeed), (timer) => step());
  }

  void stop() {
    _isRunning = false;

    if(_timer != null)
      _timer.cancel();
      
    notifyListeners();
  }

  Cell cellAt(int x, int y) {
    if(x >= _grid.length) {
      return null;
    }

    if(y >= _grid[x].length) {
      return null;
    }

    return _grid[x][y];
  }

  bool containsCreature(String type) {
    return _registeredCreatures.containsKey(type);
  }

  bool registerCreature(Creature creature) {
    if(containsCreature(creature.type)) {
      return false;
    }

    _registeredCreatures[creature.type] = Creature.clone(creature);

    final totalOccupied = settings.distribution.values.fold<double>(0.0, (current, next) => current += next);

    if(totalOccupied > 99.0) {
      final entry = settings.distribution.entries.firstWhere((x) => x.value > 1);
      settings.distribution[entry.key]--;
    }

    settings.distribution[creature.type] = 1;
    settings.notifyListeners();

    return true;
  }

  Creature getCreature(String type) {
    if(!containsCreature(type))
      return null;

    return Creature.clone(_registeredCreatures[type]);
  }

  void unregisterCreature(Creature creature) {
    _registeredCreatures.removeWhere((k, v) {
      return k == creature.type;
    });

    settings.distribution.remove(creature.type);
    settings.notifyListeners();
  }

  void buildGrid() {
    final distribution = settings.distribution;

    assert(listEquals(distribution.keys.toList(), _registeredCreatures.keys.toList()));
    
    if(_registeredCreatures.length == 0) {
      for(int x = 0; x < gridWidth; x++) {
        _grid[x] = List(gridHeight);
        
        for(int y = 0; y < gridHeight; y++) {
          _grid[x][y] = Cell(Point(x, y), null);
        }
      }
    } else {
      final rand = Random();
      //int totalWeight = distribution.values.fold(0, (currentVal, next) { return currentVal += next; });
      
      final pickRandomCreature = () {
        final randNum = rand.nextInt(101);
        var sum = 0;

        for(var entry in distribution.entries) {
          sum += entry.value;

          if(sum >= randNum)
            return entry.key;
        }

        return null;
      };

      for(int x = 0; x < gridWidth; x++) {
        _grid[x] = List(gridHeight);
        
        for(int y = 0; y < gridHeight; y++) {
          final type = pickRandomCreature();

          if(type == null)
            _grid[x][y] = Cell(Point(x, y), null); //Empty cell
          else
            _grid[x][y] = Cell(Point(x, y), Creature.clone(_registeredCreatures[type]));
        }
      }
    }

    notifyListeners();
  }

  void step() {
    var hasChanged = false;

    for(int x = 0; x < gridWidth; x++) {
      for(int y = 0; y < gridHeight; y++) {
        final cell = _grid[x][y];
        
        if(cell.isFree) {
          //Remove the creature if it's dead
          cell.creature = null;
          continue;
        }

        hasChanged = true;

        final result = cell.creature.process(_getNeighbors(cell));
        final point = result.point;

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
    else
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
