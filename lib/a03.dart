import 'dart:math';

import 'package:adventofcode2019/a.dart';

class A03 extends A {
  List<List<Line>> lines(List<String> input) =>
      input.map((w) => w.split(',')).map((w) {
        var pos = Point.zero();
        var lines = <Line>[];
        for (var direction in w) {
          var v = wire2Vector(direction);
          final end = pos + v;
          lines.add(Line.from(pos, end));
          pos = end;
        }
        return lines;
      }).toList();

  int one(List<String> input) {
    final wires = lines(input);
    var intersections = <Point>[];
    for (var u in wires.first) {
      for (var v in wires.last) {
        intersections.addAll(u.intersect(v));
      }
    }
    intersections.remove(Point.zero());

    return intersections.map((p) => p.dist).reduce((a, b) => a < b ? a : b);
  }

  int two(List<String> input) {
    final wires = lines(input);
    var intersections = <Point>[];
    for (var u in wires.first) {
      for (var v in wires.last) {
        intersections.addAll(u.intersect(v));
      }
    }
    intersections.remove(Point.zero());
    var sums = intersections.map((i) {
      var len = 0;
      for (var w in wires.first) {
        if (w.points.contains(i)) {
          len += w.points.indexOf(i);
          break;
        } else {
          len += w.len;
        }
      }
      for (var w in wires.last) {
        if (w.points.contains(i)) {
          len += w.points.indexOf(i);
          break;
        } else {
          len += w.len;
        }
      }
      return len;
    });
    return sums.reduce((a, b) => min(a, b));
  }

  Point wire2Vector(String wire) {
    var len = int.parse(wire.substring(1));
    var dir = wire[0];
    if (dir == 'R') {
      return Point(len, 0);
    } else if (dir == 'L') {
      return Point(-len, 0);
    } else if (dir == 'U') {
      return Point(0, -len);
    } else {
      return Point(0, len);
    }
  }
}

class Point {
  final int x;
  final int y;

  Point(this.x, this.y);

  factory Point.zero() => Point(0, 0);

  int get dist => x.abs() + y.abs();

  operator +(Point other) => Point(x + other.x, y + other.y);

  operator ==(other) => other is Point && x == other.x && y == other.y;

  @override
  String toString() => '($x|$y)';
}

class Line {
  final List<Point> points;

  Line(this.points);

  int get left => min(points.first.x, points.last.x);
  int get right => max(points.first.x, points.last.x);
  int get top => min(points.first.y, points.last.y);
  int get bottom => max(points.first.y, points.last.y);

  int get len => (left == right) ? (bottom - top).abs() : (right - left).abs();

  factory Line.from(Point start, Point end) {
    var points = <Point>[];
    for (var x = start.x;
        (start.x <= end.x) ? x <= end.x : x >= end.x;
        (start.x <= end.x) ? x++ : x--) {
      for (var y = start.y;
          (start.y <= end.y) ? y <= end.y : y >= end.y;
          (start.y <= end.y) ? y++ : y--) {
        points.add(Point(x, y));
      }
    }
    return Line(points);
  }

  List<Point> intersect(Line other) {
    if (right < other.left || left > other.right) {
      return List();
    } else if (bottom < other.top || top > other.bottom) {
      return List();
    }
    var intersections = <Point>[];
    other.points.forEach((p) {
      if (points.contains(p)) {
        intersections.add(p);
      }
    });
    return intersections;
  }

  @override
  String toString() => '[${points.join(', ')}]';
}
