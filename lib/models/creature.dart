part of 'terrarium.dart';

enum ProcessAction {
  none,
  move,
  eat,
  reproduce
}

class ProcessResult {
  final ProcessAction action;
  final Point point;

  ProcessResult(this.action, this.point);

  ProcessResult.none() : this(ProcessAction.none, null);
}

class Creature {
  ///The creature's type. Must be a unique value for the terrarium.
  final String type;
  ///Energy level that a creature has at the start of its life. 
  int get initialEnergy => _initialEnergy;
  set initialEnergy(int value) {
    if(value <= maxEnergy)
      _initialEnergy = value;
  }
  int _initialEnergy;
  ///Conversion ratio of food to energy. 
  ///Food energy × efficiency = gained energy.
  double get efficiency => _efficiency;
  set efficiency(double value) {
    if(value >= 0.0 && value <= 1.0)
      _efficiency = value;
  }
  double _efficiency;
  ///A creature's size. By default, creatures can only eat creatures smaller than them.
  int size;
  ///A creature's vision and movement range for each step.
  int actionRadius;
  ///Number of visible food sources needed before a creature will eat.
  int sustainability;
  ///Percentage of a creature's max energy above which it will reproduce.
  ///Used as percentages of [maxEnergy]
  double get reproduceLevel => _reproduceLevel;
  set reproduceLevel(double value) {
    if(value >= 0.0 && value <= 1.0)
      _reproduceLevel = value;
  }
  double _reproduceLevel;
  ///Percentage of a creature's max energy below which it will stop moving.
  double get moveLevel => _moveLevel;
  set moveLevel(double value) {
    if(value >= 0.0 && value <= 1.0)
      _moveLevel = value;
  }
  double _moveLevel;

  Color color;

  static final int maxEnergy = 100;

  int get energy => _energy;
  int _energy;

  bool get isDead => _energy <= 0;

  Creature({
    @required this.type,
    this.color,
    int initialEnergy = 50,
    double efficiency = 0.7,
    this.size = 50,
    this.actionRadius = 1,
    this.sustainability = 2,
    double reproduceLevel = 0.70,
    double moveLevel = 0.0
  }) : assert(type != null && type != ''),
       assert(initialEnergy <= maxEnergy),
       assert(moveLevel >= 0.0 && moveLevel <= 1.0),
       assert(efficiency >= 0.0 && efficiency <= 1.0),
       assert(reproduceLevel >= 0.0 && reproduceLevel <= 1.0) {
    _initialEnergy = initialEnergy;
    _energy = initialEnergy;
    _reproduceLevel = reproduceLevel;
    _moveLevel = moveLevel;
    _efficiency = efficiency;
    color = color ?? _generateRandomColor();
  }

  Creature.clone(Creature c) : this(
    type: c.type,
    color: c.color,
    initialEnergy: c.initialEnergy, 
    efficiency: c.efficiency, 
    size: c.size, 
    actionRadius: c.actionRadius, 
    sustainability: c.sustainability, 
    reproduceLevel: c.reproduceLevel, 
    moveLevel: c.moveLevel);

  ProcessResult process(List<Cell> neighbors) {
    if(_energy > maxEnergy * reproduceLevel)
      return _reproduce(neighbors);
    else if(energy > maxEnergy * moveLevel) 
      return _move(neighbors);

    return ProcessResult.none();
  }

  wait() {
    _energy -= 5;
  }

  ProcessResult _reproduce(List<Cell> neighbors) {
    final availableSpots = neighbors.where((c) { return c.isFree; });

    if(availableSpots.length > 0) {
      if(availableSpots.length == 1) {
        return ProcessResult(ProcessAction.reproduce, availableSpots.first.position);
      } else {
        final random = Random();
        final position = availableSpots.elementAt(random.nextInt(availableSpots.length)).position;

        return ProcessResult(ProcessAction.reproduce, position);
      }
    }

    return ProcessResult.none();
  }

  ProcessResult _move(List<Cell> neighbors) {
    var action = ProcessAction.eat;

    var availableSpots = neighbors.where((c) {
      if(c.creature != null)
        return c.creature.size < size;

      return false;
    });

    //If there's not enough food, try to move
    if(availableSpots.length < sustainability) {
      action = ProcessAction.move;
      availableSpots = neighbors.where((c) { return c.isFree; });
    }

    if(availableSpots.length > 0) {
      if(availableSpots.length == 1) {
        return ProcessResult(action, availableSpots.first.position);
      } else {
        final random = Random();
        final position = availableSpots.elementAt(random.nextInt(availableSpots.length)).position;

        return ProcessResult(action, position);
      }
    }

    return ProcessResult.none();
  }

  static Color _generateRandomColor() {
      final random = Random();
      return Color.fromRGBO(random.nextInt(256), random.nextInt(256), random.nextInt(256), 1.0);
  }
}
