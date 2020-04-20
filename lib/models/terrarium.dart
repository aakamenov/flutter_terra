library terrarium;

import 'dart:math';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
    assert(x >= 0 && x < gridWidth);
    assert(y >= 0 && y < gridHeight);

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
    final largestRadius = _getLargestRadius();
    var bufferLength = 0;

    for(int i = 1; i <= largestRadius; i++) {
      bufferLength += i * 8;
    }

    final buffer = List<Cell>(bufferLength);

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
        
        final manager = _NeighborsManager(_grid, buffer, cell.position, cell.creature.actionRadius);
        final result = cell.creature.process(manager);
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

  int _getLargestRadius() {
    var largest = 1;

    for(var creature in _registeredCreatures.values) {
      final radius = creature.actionRadius;
      
      if(radius > largest)
        largest = radius;
    }
    
    return largest;
  }
}

class _NeighborsManager {
  static Random _random = Random();

  final List<List<Cell>> _grid;
  final List<Cell> _buffer;
  final Point _position;
  final int _radius;

  int _freeIndex;
  int _occupiedIndex = -1;
  bool _isCached = false;

  _NeighborsManager(this._grid, this._buffer, this._position, this._radius) {
    _freeIndex = _buffer.length;
  }

  Cell getRandomFreeCell() {
    if(!_isCached)
      _populateNeighbors();

    if(_freeIndex == _buffer.length) //No free cells
      return null;
    
    final randomIndex = (_random.nextInt(_buffer.length) + _freeIndex).clamp(_freeIndex, _buffer.length - 1);

    return _buffer[randomIndex];
  }

  Cell getRandomOccupiedCell() {
    if(!_isCached)
      _populateNeighbors();
    
    return _buffer[_random.nextInt(_occupiedIndex + 1)];
  }

  List<Cell> filterOccupied(bool test(Cell c)) {
    if(!_isCached)
      _populateNeighbors();

    //TODO: Still need to avoid using a growable list
    final result = List<Cell>();

    for(int i = 0; i <= _occupiedIndex; i++) {
      if(test(_buffer[i]))
        result.add(_buffer[i]);
    }

    return result;
  }

  void _populateNeighbors() {
    final xLo = max(0, _position.x - _radius);
    final yLo = max(0, _position.y - _radius);
    final xHi = min(_position.x + _radius, _grid.length - 1);
    final yHi = min(_position.y + _radius, _grid[0].length - 1);

    for (var x = xLo; x <= xHi; ++x) {
      for (var y = yLo; y <= yHi; ++y) {
        if (x != _position.x || y != _position.y) {
          final cell = _grid[x][y];

          if(cell.isFree)
            _buffer[--_freeIndex] = cell;
          else
            _buffer[++_occupiedIndex] = cell;
        }
      }
    }

    _isCached = true;
  }
}
