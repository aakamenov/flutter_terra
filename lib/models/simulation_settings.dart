part of 'terrarium.dart';

class SimulationSettings extends ChangeNotifier {
  static const minSpeed = 100;
  static const maxSpeed = 1000;

  Map<String, int> distribution = Map<String, int>();

  int get simulationSpeed => _simulationSpeed;
  set simulationSpeed(int value) {
    assert(simulationSpeed >= minSpeed && simulationSpeed <= maxSpeed);
    _simulationSpeed = value;
  }
  int _simulationSpeed = minSpeed;
}
