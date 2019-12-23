import 'package:adventofcode2019/a.dart';

class A20 extends AA {
  Future<int> one(List<String> input) async {
    var d = Dungeon.parse(input);
    return d.scan('AA', 'ZZ');
  }

  Future<int> two(List<String> input) async {
    var d = DungeonZ.parse(input);
    return d.scan('AA', 'ZZ');
  }
}

class DungeonZ {
  var points = <PointZ>[];

  DungeonZ();

  factory DungeonZ.parse(List<String> input) {
    var d = DungeonZ();
    for (var y = 0; y < input.length; y++) {
      var line = input[y];
      for (var x = 0; x < line.length; x++) {
        var char = line[x];
        if (char == '.') {
          d.points.add(PointZ(x, y));
        } else if (char == '#' || char == ' ') {
          // ignore
        } else {
          var p = PointZ(x, y, key: char);
          d.points.add(p);
        }
      }
    }
    for (var portal in d.points.where((p) => p.isKey)) {
      if (portal.x < 2 ||
          portal.y < 2 ||
          portal.x > input.first.length - 3 ||
          portal.y > input.length - 3) {
        portal.outer = true;
      }
      var r = d.find(portal.right) ?? d.find(portal.bottom);
      if (r != null && r.isKey) {
        var key = '${portal.key}${r.key}';
        r.key = key;
        portal.key = key;
      }
    }
    print(d.points.where((p) => p.isKey));
    return d;
  }

  PointZ find(PointZ o) => points.firstWhere((p) => p == o, orElse: () => null);

  int scan(String from, String to) {
    var dist = 0;
    var thisRound = [points.where((p) => p.key == from).toList()];
    thisRound.first.forEach((p) => p.dist = [0]);
    var nextRound = <List<PointZ>>[];
    while (thisRound.isNotEmpty) {
      dist++;
      for (int d in Iterable.generate(thisRound.length)) {
        while (nextRound.length <= d + 1) {
          nextRound.add(<PointZ>[]);
        }
        for (var q in thisRound[d].expand((a) => a.adjacent)) {
          var index = points.indexOf(q);
          if (index > -1 &&
              (points[index].dist.length <= d ||
                  points[index].dist[d] == null ||
                  points[index].dist[d] > dist)) {
            while (points[index].dist.length <= d) {
              points[index].dist.add(null);
            }
            var z = points[index];
            z.dist[d] = dist;
            if (z.key == to && d == 0) {
              return dist - 2;
            }
            if (z.isKey) {
              if (z.key != from && z.key != to) {
                if (z.outer) {
                  if (d > 0) {
                    var portal =
                        points.where((p) => p.key == z.key && !p.outer);
                    portal.forEach((p) {
                      while (p.dist.length < d) {
                        p.dist.add(null);
                      }
                      p.dist[d - 1] = dist;
                    });
                    nextRound[d - 1].addAll(portal
                        .expand((p) => p.adjacent.map(find))
                        .where((p) => p != null));
                  }
                } else {
                  var portal = points.where((p) => p.key == z.key && p.outer);
                  portal.forEach((p) {
                    while (p.dist.length <= d + 1) {
                      p.dist.add(null);
                    }
                    return p.dist[d + 1] = dist;
                  });

                  nextRound[d + 1].addAll(portal
                      .expand((p) => p.adjacent.map(find))
                      .where((p) => p != null));
                }
                z.dist[d] = dist;
              }
            } else {
              nextRound[d].add(z);
            }
          }
        }
      }
      thisRound = nextRound;
      while (thisRound.last.isEmpty) {
        thisRound.removeLast();
      }
      nextRound = <List<PointZ>>[];
    }
    return -1;
  }
}

class PointZ {
  final int x;
  final int y;
  String key;
  List<int> dist = [null];
  bool outer = false;

  PointZ(this.x, this.y, {this.key});

  operator ==(dynamic other) => other is PointZ && other.x == x && other.y == y;

  PointZ get left => PointZ(x - 1, y);
  PointZ get top => PointZ(x, y - 1);
  PointZ get right => PointZ(x + 1, y);
  PointZ get bottom => PointZ(x, y + 1);

  List<PointZ> get adjacent => [left, top, right, bottom];
  bool get isKey => key != null;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  operator +(PointZ o) => PointZ(o.x + x, o.y + y);

  @override
  String toString() => '$x|$y($key/$outer)';
}

class Dungeon {
  var points = <Point>[];

  Dungeon();

  factory Dungeon.parse(List<String> input) {
    var d = Dungeon();
    for (var y = 0; y < input.length; y++) {
      var line = input[y];
      for (var x = 0; x < line.length; x++) {
        var char = line[x];
        if (char == '.') {
          d.points.add(Point(x, y));
        } else if (char == '#' || char == ' ') {
          // ignore
        } else {
          var p = Point(x, y, key: char);
          d.points.add(p);
        }
      }
    }
    for (var portal in d.points.where((p) => p.isKey)) {
      var r = d.find(portal.right) ?? d.find(portal.bottom);
      if (r != null && r.isKey) {
        var key = '${portal.key}${r.key}';
        r.key = key;
        portal.key = key;
      }
    }
    return d;
  }

  Point find(Point o) => points.firstWhere((p) => p == o, orElse: () => null);

  int scan(String from, String to) {
    points.forEach((p) => p.dist = null);
    var dist = 0;
    var thisRound = points.where((p) => p.key == from);
    thisRound.forEach((p) => p.dist = dist);
    var nextRound = <Point>[];
    while (thisRound.isNotEmpty) {
      dist++;
      print('$dist: $thisRound');
      for (var q in thisRound.expand((a) => a.adjacent)) {
        var index = points.indexOf(q);
        if (index > -1 &&
            (points[index].dist == null || points[index].dist > dist)) {
          var z = points[index];
          z.dist = dist;
          if (z.isKey) {
            if (z.key == to) {
              return dist - 2;
            }
            var portal = points.where((p) => p.key == z.key);
            portal.forEach((p) => p.dist = dist);
            nextRound.addAll(portal
                .expand((p) => p.adjacent.map(find))
                .where((p) => p != null));
          } else {
            nextRound.add(z);
          }
        }
      }
      thisRound = nextRound;
      nextRound = <Point>[];
    }
    return -1;
  }
}

class Point {
  final int x;
  final int y;
  String key;
  int dist;

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
  String toString() => '$x|$y($key/$dist)';
}
