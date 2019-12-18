import 'dart:isolate';

import 'package:adventofcode2019/a.dart';

var best = 99999;

class Dungeon {
  var points = <Point>[];
  var doors = <String, Point>{};
  Point start;
  int distUntilHere = 0;

  Dungeon();

  Dungeon copy(Point pos, int dist) => Dungeon()
    ..points = points.map((p) => p.withDist(null)).toList()
    ..doors = Map<String, Point>.from(doors)
    ..distUntilHere = dist
    ..start = pos.withDist(0);

  factory Dungeon.parse(List<String> input) {
    var d = Dungeon();
    for (var y = 0; y < input.length; y++) {
      var line = input[y];
      for (var x = 0; x < line.length; x++) {
        var char = line[x];
        if (char == '.') {
          d.points.add(Point(x, y));
        } else if (char == '@') {
          d.start = Point(x, y, dist: 0, key: '@');
          d.points.add(d.start);
        } else if (char != '#') {
          var c = char.toLowerCase();
          var p = Point(x, y, key: c);
          if (c == char) {
            d.points.add(p);
          } else {
            d.doors[c] = p;
          }
        }
      }
    }
    return d;
  }

  int scan(Point current) {
    int i = 0;
    for (var p in current.adjacent) {
      var index = points.indexOf(p);
      if (index >= 0 &&
          (points[index].dist == null ||
              points[index].dist > current.dist + 1)) {
        points[index] = points[index].withDist(current.dist + 1);
        if (!points[index].isKey) {
          i++;
        }
      }
    }
    return i;
  }

  Future<int> solve([String id]) async {
    points.removeWhere((p) => p == start);
    if (start.isKey) {
      if (doors.containsKey(start.key)) {
        points.add(doors.remove(start.key).withoutKey());
      }
      points.add(start.withoutKey());
    }
    if (points.every((p) => !p.isKey)) {
      if (best > distUntilHere) {
        best = distUntilHere;
        print('$id >>>> $distUntilHere');
      }
      return distUntilHere;
    }

    var dist = 0;
    var i = 1;
    while (i > 0) {
      i = 0;
      for (var p in points.where((q) => q.dist == dist && !q.isKey)) {
        i += scan(p);
      }
      dist++;
    }

    var check = points.where((p) => p.dist != null && p.isKey).toList();
    check.sort((k, j) => k.dist.compareTo(j.dist));

    // if (keypair.length > 30) {
    //   var runners = <Future>[];
    //   var receivePort = ReceivePort();
    //   for (var k in check) {
    //     var kp = keypair[k.key];
    //     Dungeon d = copy(kp.key, k.value.key.dist + distUntilHere);
    //     var message = Message(receivePort.sendPort, d);
    //     runners.add(Isolate.spawn(solveDungeon, message));
    //   }

    //   await runners.forEach((r) async => await r);
    //   var dist = await receivePort
    //       .take(runners.length)
    //       .map((i) => i as int)
    //       .reduce((a, b) => min(a, b));

    //   if (dist == -1) {
    //     var keys = keypair.keys.toList();
    //     keys.sort();
    //     throw Exception('No solution with $keys');
    //   }
    //   return dist;
    // } else {

    var sol;
    for (var k in check) {
      Dungeon d = copy(k, k.dist + distUntilHere);
      var s = await d.solve(
          id == null ? '${k.key}[${k.dist}]' : '$id, ${k.key}[${k.dist}]');

      if (sol == null || s < sol) {
        sol = s;
      }
    }

    return sol;
    // }
  }
}

class Message {
  final SendPort send;
  final Dungeon dungeon;

  Message(this.send, this.dungeon);
}

void solveDungeon(Message m) async {
  var sol = await m.dungeon.solve();
  m.send.send(sol);
}

class A18 extends AA {
  Future<int> one(List<String> input) async {
    var d = Dungeon.parse(input);
    return await d.solve();
  }

  Future<int> two(List<String> input) async {
    return 0;
  }
}

class Point {
  final int x;
  final int y;
  final dist;
  final String key;

  Point(this.x, this.y, {this.dist, this.key});

  Point withDist(int d) => Point(x, y, dist: d, key: key);
  Point withoutKey() => Point(x, y, dist: dist, key: null);

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
  String toString() => '$x|$y[$dist]($key)';
}
