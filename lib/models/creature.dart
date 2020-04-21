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
  static Random _random = Random();

  ///The creature's type. Must be a unique value for the terrarium.
  final String type;
  ///Energy level that a creature has at the start of its life. 
  int get initialEnergy => _initialEnergy;
  set initialEnergy(int value) {
    assert(value >= 1 && value <= maxEnergy);
    _initialEnergy = value;
  }
  int _initialEnergy;
  ///Conversion ratio of food to energy. 
  ///Food energy × efficiency = gained energy.
  double get efficiency => _efficiency;
  set efficiency(double value) {
    assert(value >= 0.0 && value <= 1.0);
    _efficiency = value;
  }
  double _efficiency;
  ///A creature's size. Creatures can only eat creatures smaller than them.
  int size;
  ///A creature's vision and movement range for each step.
  int actionRadius;
  ///Number of visible food sources needed before a creature will eat.
  int sustainability;
  ///Percentage of a creature's max energy above which it will reproduce.
  ///Used as percentages of [maxEnergy]
  double get reproduceLevel => _reproduceLevel;
  set reproduceLevel(double value) {
    assert(value >= 0.0 && value <= 1.0);
    _reproduceLevel = value;
  }
  double _reproduceLevel;
  ///Percentage of a creature's max energy below which it will stop moving.
  double get moveLevel => _moveLevel;
  set moveLevel(double value) {
    assert(value >= 0.0 && value <= 1.0);
    _moveLevel = value;
  }
  double _moveLevel;

  Color color;

  int get maxEnergy => _maxEnergy;
  set maxEnergy(int value) {
    assert(value > 0);
    _maxEnergy = value;
    initialEnergy = _initialEnergy.clamp(1, _maxEnergy);
    waitEnergyModifier = _waitEnergyModifier.clamp(0, _maxEnergy);
  }
  int _maxEnergy = 100;

  int get energy => _energy;
  int _energy;

  bool get isDead => _energy <= 0;

  bool gainEnergyOnWait;

  int get waitEnergyModifier => _waitEnergyModifier;
  set waitEnergyModifier(int value) {
    assert(value >= 0 && value <= maxEnergy);
    _waitEnergyModifier = value;
  }
  int _waitEnergyModifier;

  Creature({
    @required this.type,
    this.color,
    int initialEnergy = 50,
    double efficiency = 0.7,
    this.size = 50,
    this.actionRadius = 1,
    this.sustainability = 2,
    double reproduceLevel = 0.70,
    double moveLevel = 0.0,
    int maxEnergy = 100,
    this.gainEnergyOnWait = false,
    int waitEnergyModifier = 5
  }) : assert(type != null && type != ''),
       assert(initialEnergy <= maxEnergy),
       assert(moveLevel >= 0.0 && moveLevel <= 1.0),
       assert(efficiency >= 0.0 && efficiency <= 1.0),
       assert(reproduceLevel >= 0.0 && reproduceLevel <= 1.0) {
    _maxEnergy = maxEnergy;
    this.initialEnergy = initialEnergy;
    this.waitEnergyModifier = waitEnergyModifier;
    this.maxEnergy = maxEnergy;
    _energy = initialEnergy;

    this.reproduceLevel = reproduceLevel;
    this.moveLevel = moveLevel;
    this.efficiency = efficiency;
    this.color = color ?? _generateRandomColor();
  }

  Creature.clone(Creature c, { String newType }) : this(
    type: newType == null || newType.isEmpty ? c.type : newType,
    color: c.color,
    maxEnergy: c.maxEnergy,
    initialEnergy: c.initialEnergy, 
    efficiency: c.efficiency, 
    size: c.size, 
    actionRadius: c.actionRadius, 
    sustainability: c.sustainability, 
    reproduceLevel: c.reproduceLevel, 
    moveLevel: c.moveLevel,
    gainEnergyOnWait: c.gainEnergyOnWait,
    waitEnergyModifier: c.waitEnergyModifier);

  ProcessResult process(_NeighborsManager manager) {
    if(_energy > maxEnergy * reproduceLevel)
      return _reproduce(manager);
    else if(energy > maxEnergy * moveLevel) 
      return _move(manager);

    return ProcessResult.none();
  }

  wait() {
    if(gainEnergyOnWait)
      _energy += 5;
    else
      _energy -= 5;
  }

  ProcessResult _reproduce(_NeighborsManager manager) {
    final cell = manager.getRandomFreeCell();

    if(cell != null) {
        return ProcessResult(ProcessAction.reproduce, cell.position);
    }

    return ProcessResult.none();
  }

  ProcessResult _move(_NeighborsManager manager) {  
    final edibleCreatures = manager.filterOccupied((c) {
        return c.creature.size < size;
    });

    //If there's not enough food, try to move
    if(edibleCreatures.length < sustainability) {
      final cell = manager.getRandomFreeCell();

      if(cell != null) {
        return ProcessResult(ProcessAction.move, cell.position);
      }

      return ProcessResult.none();
    } else {
      final cell = edibleCreatures[_random.nextInt(edibleCreatures.length)];

      return ProcessResult(ProcessAction.eat, cell.position);
    }
  }

  static Color _generateRandomColor() {
      return Color.fromRGBO(_random.nextInt(256), _random.nextInt(256), _random.nextInt(256), 1.0);
  }
}
