import 'dart:math';

import 'package:adventofcode2019/a.dart';

var globalBest = 9999;

class Dungeon {
  Map<String, Map<String, int>> points = {};

  Dungeon();

  Dungeon copy() => Dungeon()
    ..points = Map.fromEntries(
        points.entries.map((e) => MapEntry(e.key, Map.from(e.value))));

  static List<Point> parse(List<String> input) {
    var points = <Point>[];
    int start = 1;
    for (var y = 0; y < input.length; y++) {
      var line = input[y];
      for (var x = 0; x < line.length; x++) {
        var char = line[x];
        if (char == '.') {
          points.add(Point(x, y));
        } else if (char == '@') {
          var p = Point(x, y, key: '${start++}');
          points.add(p);
        } else if (char != '#') {
          var p = Point(x, y, key: char);
          points.add(p);
        }
      }
    }
    return points;
  }

  static void calculate(List<Point> points) {
    int i = 0;
    var interestingPoints = points.where((p) => p.isKey);
    for (var p in interestingPoints) {
      p.distances = scan(points, p);
      print('${i++}/${interestingPoints.length}: $p');
    }
  }

  static Map<String, int> scan(List<Point> points, Point current) {
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

  void removePoint(String q) {
    var p = points.remove(q);
    for (var r in p.entries) {
      var k = r.key;
      var d = r.value;
      points[k].remove(q);
      for (var n in p.entries) {
        if (n.key != k) {
          if (points[k].containsKey(n.key)) {
            points[k][n.key] = min(points[k][n.key], n.value + d);
          } else {
            points[k][n.key] = n.value + d;
          }
        }
      }
    }
    if (q.toUpperCase() != q) {
      takeKey(q);
    }
  }

  void takeKey(String q) {
    if (q.toUpperCase() == q || !points.containsKey(q.toUpperCase())) {
      return;
    }
    removePoint(q.toUpperCase());
  }

  Future<int> solve(List<String> positions, int dist) async {
    positions.removeWhere((p) => points[p].isEmpty);
    positions.forEach(takeKey);
    var replace = positions
        .where((p) =>
            points[p].length == 1 &&
            points[p].keys.first.toLowerCase() == points[p].keys.first)
        .toList();
    while (replace.isNotEmpty) {
      dist +=
          replace.map((p) => points[p].values.first).reduce((a, b) => a + b);
      for (var r in replace) {
        positions.remove(r);
        var newPos = points[r].keys.first;
        positions.add(newPos);
        takeKey(newPos);
        removePoint(r);
      }
      positions.removeWhere((p) => points[p].isEmpty);
      if (positions.isEmpty) {
        return dist;
      }
      replace = positions
          .where((p) =>
              points[p].length == 1 &&
              points[p].keys.first.toLowerCase() == points[p].keys.first)
          .toList();
    }

    var nextKeys = <String, int>{};
    for (var q in positions) {
      nextKeys.addAll(points[q]);
    }

    var order = nextKeys.entries
        .where(
            (e) => e.key.toLowerCase() == e.key && nextKeys.containsKey(e.key))
        .toList();
    order.sort((a, b) => nextKeys[a.key].compareTo(nextKeys[b.key]));

    var shortest;
    for (var route in order) {
      var origin =
          positions.firstWhere((p) => points[p].keys.contains(route.key));
      var d = route.value + dist;
      if (shortest != null && shortest < d) {
        break;
      }
      var c = copy();
      var np = List<String>.from(positions);
      c.removePoint(origin);
      np.remove(origin);
      np.add(route.key);
      int solution = await c.solve(np, d);
      if (solution != null && (shortest == null || shortest > solution)) {
        shortest = solution;
        if (globalBest > shortest) {
          globalBest = shortest;
          print('new shortest: $shortest');
        }
      }
    }
    return shortest;
  }
}

class A18 extends AA {
  Future<int> one(List<String> input) async {
    var points = Dungeon.parse(input);
    Dungeon.calculate(points);
    print('finished calculating');
    var d = Dungeon();
    d.points = Map.fromEntries(points
        .where((p) => p.distances.isNotEmpty)
        .toList()
        .map((p) => MapEntry(p.key, p.distances)));
    return await d.solve(['1'], 0);
  }

  Future<int> two(List<String> input) async {
    var points = Dungeon.parse(input);
    Dungeon.calculate(points);
    print('finished calculating');
    var d = Dungeon();
    d.points = Map.fromEntries(points
        .where((p) => p.distances.isNotEmpty)
        .toList()
        .map((p) => MapEntry(p.key, p.distances)));
    return await d.solve(['1', '2', '3', '4'], 0);
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
  String toString() => '$key${distances}';
}
