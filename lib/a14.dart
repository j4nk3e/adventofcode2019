import 'dart:math';

import 'package:adventofcode2019/a.dart';

class A14 extends A {
  int one(List<String> input) {
    var reactions = Map.fromEntries(input.map((l) {
      var s = l.split(' => ');
      var i = s.first.split(', ').map((c) => Chem.from(c));
      var c = Chem.from(s.last);
      c.input = Map.fromEntries(i.map((i) => MapEntry(i.id, i.output)));
      return MapEntry(c.id, c);
    }));
    reactions['FUEL'].req = 1;
    int ore = 0;
    while (!reactions.values.every((r) => r.req <= 0)) {
      final r = reactions.values.firstWhere((r) => r.req > 0);
      while (r.req > 0) {
        for (var i in r.input.entries) {
          if (i.key == 'ORE') {
            ore += i.value;
          } else {
            reactions[i.key].req += i.value;
          }
        }
        r.req -= r.output;
      }
    }
    return ore;
  }

  int two(List<String> input) {
    var reactions = Map.fromEntries(input.map((l) {
      var s = l.split(' => ');
      var i = s.first.split(', ').map((c) => Chem.from(c));
      var c = Chem.from(s.last);
      c.input = Map.fromEntries(i.map((i) => MapEntry(i.id, i.output)));
      return MapEntry(c.id, c);
    }));
    var fuel = 1;
    var tooHigh = 0;
    while (true) {
      reactions['FUEL'].req = fuel;
      int ore = 0;
      while (!reactions.values.every((r) => r.req <= 0)) {
        final r = reactions.values.firstWhere((r) => r.req > 0);
        var k = r.req ~/ r.output;
        if (r.req % r.output > 0) {
          k++;
        }
        for (var i in r.input.entries) {
          if (i.key == 'ORE') {
            ore += i.value * k;
          } else {
            reactions[i.key].req += i.value * k;
          }
        }
        r.req -= r.output * k;
      }
      if (ore <= 1000000000000) {
        if (tooHigh == fuel + 1) {
          return fuel - 2;
        }
        fuel += max(1, 1000000000000 / ore * fuel * 0.001).floor();
      } else if (ore > 1000000000000) {
        tooHigh = fuel;
        fuel--;
      }
    }
  }
}

class Chem {
  final String id;
  int output;
  int req = 0;

  Map<String, int> input;

  Chem(this.id, this.output);

  factory Chem.from(String s) {
    var c = s.split(' ');
    return Chem(c.last, int.parse(c.first));
  }

  @override
  String toString() => '$input => $output $id';
}
