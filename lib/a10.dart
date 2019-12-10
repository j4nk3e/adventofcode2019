import 'dart:math';

import 'package:adventofcode2019/a.dart';
import 'package:quiver/iterables.dart';
import 'package:collection/collection.dart';

class A10 extends A {
  int one(List<String> input) {
    var asteroids = parse(input);
    return max(asteroids.map((center) =>
        groupBy(asteroids.orderFrom(center), (a) => center.angle(a)).length));
  }

  int two(List<String> input) {
    var base = Asteroid(11, 13);
    var asteroids = parse(input).orderFrom(base)..where((a) => a != base);
    var angles = groupBy(asteroids, (Asteroid a) => base.angle(a));
    Asteroid hit;
    var sniped = 0;
    all:
    while (true) {
      for (var angle in angles.entries) {
        final los = angle.value;
        if (los.isNotEmpty) {
          hit = los.removeAt(0);
          sniped++;
          if (sniped == 200) {
            break all;
          } else {
            continue;
          }
        }
      }
    }
    print(hit);
    return hit.x * 100 + hit.y;
  }

  List<Asteroid> parse(List<String> input) => input
      .asMap()
      .entries
      .map((line) => line.value
          .split('')
          .asMap()
          .entries
          .where((e) => e.value != '.')
          .map((e) => Asteroid(e.key, line.key)..c = e.value))
      .expand((e) => e)
      .toList();
}

class Asteroid {
  final int x;
  final int y;
  String c = '#';

  Asteroid(this.x, this.y);

  toString() => '$c($x|$y)';

  operator ==(other) => other is Asteroid && other.x == x && other.y == y;

  double angle(Asteroid other) {
    var ac = (360 + (atan2(other.y - y, other.x - x) / pi * 180 + 90)) % 360;
    return ac;
  }

  double dist(Asteroid other) {
    return pow(other.y - y, 2.0) + pow(other.x - x, 2.0);
  }

  bool between(Asteroid a, Asteroid b) {
    final ab = a.angle(this);
    final ac = a.angle(b);
    final db = a.dist(this);
    final dc = a.dist(b);
    return ab == ac && db < dc;
  }
}

extension AsteroidList<T extends Asteroid> on List<Asteroid> {
  List<T> orderFrom(Asteroid base) {
    var s = List<T>.from(this);
    s.sort((a, b) {
      var ang = base.angle(a).compareTo(base.angle(b));
      if (ang != 0) {
        return ang;
      }
      return base.dist(a).compareTo(base.dist(b));
    });
    return s;
  }
}
