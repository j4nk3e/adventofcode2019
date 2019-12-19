import 'dart:math';

import 'package:adventofcode2019/a.dart';

class Dungeon {
  var points = <Point>[];

  Dungeon();

  Dungeon copy() => Dungeon()
    ..points = points
        .map((p) => (Point(p.x, p.y, key: p.key)..distances = p.distances))
        .toList();

  factory Dungeon.parse(List<String> input) {
    var d = Dungeon();
    for (var y = 0; y < input.length; y++) {
      var line = input[y];
      for (var x = 0; x < line.length; x++) {
        var char = line[x];
        if (char == '.') {
          d.points.add(Point(x, y));
        } else if (char != '#') {
          var p = Point(x, y, key: char);
          d.points.add(p);
        }
      }
    }
    return d;
  }

  void calculate() {
    int i = 0;
    var interestingPoints = points.where((p) => p.isKey);
    for (var p in interestingPoints) {
      p.distances = scan(p);
      print('${i++}/${interestingPoints.length}');
    }
  }

  Map<String, int> scan(Point current) {
    Map<String, int> distances = {};
    points.forEach((p) => p.dist = null);
    var dist = 0;
    current.dist = 0;
    var thisRound = <Point>[current];
    var nextRound = <Point>[];
    while (thisRound.isNotEmpty) {
      dist++;
      for (var q in thisRound.expand((a) => a.adjacent)) {
        var index = points.indexOf(q);
        if (index > -1 &&
            (points[index].dist == null || points[index].dist > dist)) {
          var z = points[index];
          z.dist = dist;
          if (z.isKey) {
            distances[z.key] = z.dist;
          } else {
            nextRound.add(z);
          }
        }
      }
      thisRound = nextRound;
      nextRound = <Point>[];
    }
    return distances;
  }

  int solve(final String q, final int dist) {
    if (points.where((p) => p.key.toLowerCase() == p.key).length == 1) {
      return dist;
    }
    var qPoint = points.firstWhere((p) => p.key == q);

    for (var r in points) {
      r.distances = Map.from(r.distances);
      for (var s in qPoint.distances.entries) {
        if (r.distances.containsKey(q)) {
          if (r.distances.containsKey(s.key)) {
            r.distances[s.key] =
                min(r.distances[s.key], r.distances[q] + s.value);
          } else {
            r.distances[s.key] = r.distances[q] + s.value;
          }
        }
      }
    }

    var door =
        points.firstWhere((p) => p.key == q.toUpperCase(), orElse: () => null);
    if (door != null) {
      points.remove(door);
      for (var r in points) {
        var d = q.toUpperCase();
        for (var s in door.distances.entries) {
          if (r.distances.containsKey(d)) {
            if (r.distances.containsKey(s.key)) {
              r.distances[s.key] =
                  min(r.distances[s.key], r.distances[d] + s.value);
            } else {
              r.distances[s.key] = r.distances[d] + s.value;
            }
          }
        }
      }
    }
    var nextKeys = qPoint.distances;
    points.remove(qPoint);

    var order = points
        .where(
            (e) => e.key.toLowerCase() == e.key && nextKeys.containsKey(e.key))
        .toList();
    order.sort((a, b) => nextKeys[a.key].compareTo(nextKeys[b.key]));
    assert(order.isNotEmpty);

    var shortest;
    for (var route in order) {
      var d = nextKeys[route.key] + dist;
      if (shortest != null && shortest < d) {
        break;
      }
      var sub = copy();
      var solution = sub.solve(route.key, d);
      if (shortest == null || shortest > solution) {
        shortest = solution;
        if (globalBest > shortest) {
          globalBest = shortest;
          print(shortest);
        }
      }
    }
    assert(shortest != null);
    return shortest;
  }
}

var globalBest = 9999;

class A18 extends AA {
  Future<int> one(List<String> input) async {
    var d = Dungeon.parse(input);
    d.calculate();
    print('finished calculating');
    d.points = d.points.where((p) => p.distances.isNotEmpty).toList();
    return d.solve('@', 0);
  }

  Future<int> two(List<String> input) async {
    return 0;
  }
}

class Point {
  final int x;
  final int y;
  final String key;
  int dist;
  Map<String, int> distances = {};

  Point(this.x, this.y, {this.key});

  operator ==(dynamic other) => other is Point && other.x == x && other.y == y;

  Point get left => Point(x - 1, y);
  Point get top => Point(x, y - 1);
  Point get right => Point(x + 1, y);
  Point get bottom => Point(x, y + 1);

  List<Point> get adjacent => [left, top, right, bottom];
  bool get isKey => key != null;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  operator +(Point o) => Point(o.x + x, o.y + y);

  @override
  String toString() => '$x|$y($key/${distances.length})';
}
