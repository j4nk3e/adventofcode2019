import 'package:adventofcode2019/a.dart';

class A01 extends A {
  int one(List<String> lines) => lines
      .map((l) => int.parse(l))
      .map(fuelConsumption)
      .reduce((a, b) => a + b);

  int two(List<String> lines) => lines
      .map((l) => int.parse(l))
      .map(recursiveFuelConsumption)
      .reduce((a, b) => a + b);

  static int fuelConsumption(int mass) => (mass / 3).floor() - 2;

  static int recursiveFuelConsumption(int mass) {
    var sum = 0;
    var part = mass;
    do {
      part = fuelConsumption(part);
      sum += part;
    } while (part >= 9);
    return sum;
  }
}
