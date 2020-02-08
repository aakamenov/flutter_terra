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
  final int initialEnergy;
  ///Conversion ratio of food to energy. 
  ///Food energy × efficiency = gained energy.
  final double efficiency;
  ///A creature's size. By default, creatures can only eat creatures smaller than them.
  final int size;
  ///A creature's vision and movement range for each step.
  final int actionRadius;
  ///Number of visible food sources needed before a creature will eat.
  final int sustainability;
  ///Percentage of a creature's max energy above which it will reproduce.
  ///Used as percentages of [maxEnergy]
  final double reproduceLevel;
  ///Percentage of a creature's max energy below which it will stop moving.
  final double moveLevel;

  Color get color => _color;
  Color _color;

  static final int maxEnergy = 100;

  int get energy => _energy;
  int _energy;

  bool get isDead => _energy <= 0;

  Creature({
    @required this.type,
    Color color,
    this.initialEnergy = 50,
    this.efficiency = 0.7,
    this.size = 50,
    this.actionRadius = 1,
    this.sustainability = 2,
    this.reproduceLevel = 0.70,
    this.moveLevel = 0.0
  }) : assert(type != null && type != ''),
       assert(initialEnergy <= maxEnergy),
       assert(moveLevel >= 0.0 && moveLevel <= 1.0),
       assert(reproduceLevel >= 0.0 && reproduceLevel <= 1.0) {
    _energy = initialEnergy;
    _color = color ?? _generateRandomColor();
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
