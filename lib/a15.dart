import 'package:adventofcode2019/a.dart';
import 'package:adventofcode2019/intcode.dart';
import 'package:quiver/iterables.dart';

class A15 extends A {
  int one(List<String> input) {
    var intcode = IntCode.from(input);
    Ship ship = Ship();
    ship.tiles.add(Tile(0, 0, type: 'X'));
    for (int i = 0; true; i++) {
      var o = intcode.run(ship.bot.direction);
      if (o == 0) {
        ship.add(Tile(ship.bot.nextX(), ship.bot.nextY(), type: '#'));
      } else if (o == 1) {
        ship.bot.move();
        ship.find(ship.bot.x, ship.bot.y).visited++;
        ship.add(Tile(ship.bot.x, ship.bot.y, type: '.'));
      } else if (o == 2) {
        ship.bot.move();
        print('OXYGEN FOUND AT ${ship.bot.x}/${ship.bot.y}');
        return ship.add(Tile(ship.bot.x, ship.bot.y, type: 'O'));
      }
      print(ship.toString());
      print('=== $i | $o => ${ship.bot.x}/${ship.bot.y} ${ship.bot.direction}');
      ship.scan();
    }
  }

  int two(List<String> input) {
    var intcode = IntCode.from(input);
    Ship ship = Ship();
    ship.tiles.add(Tile(0, 0, type: 'X'));
    for (int i = 0; true; i++) {
      var o = intcode.run(ship.bot.direction);
      if (o == 0) {
        ship.add(Tile(ship.bot.nextX(), ship.bot.nextY(), type: '#'));
      } else {
        ship.bot.move();
        if (o == 1) {
          ship.add(Tile(ship.bot.x, ship.bot.y, type: '.'));
        } else if (o == 2) {
          ship.add(Tile(ship.bot.x, ship.bot.y, type: 'O'));
          ship.find(ship.bot.x, ship.bot.y).oxygen = 0;
        }
        var t = ship.find(ship.bot.x, ship.bot.y);
        ship.oxyCheck(t);
        t.visited++;
      }
      print(ship.toString());
      var l = ship.tiles.where((t) => t.isKnown && !t.isWall).length;
      var lo = ship.tiles.where((t) => t.oxygen != null).length;
      print(
          '=== $i $l/$lo ${ship.maxOx} | $o => ${ship.bot.x}/${ship.bot.y} ${ship.bot.direction}');
      if (l == lo) {
        return ship.maxOx;
      }
      ship.scan();
    }
  }
}

class Ship {
  List<Tile> tiles = [];
  Bot bot = Bot();
  int maxOx = 0;

  @override
  String toString() {
    var minX = min(tiles.map((t) => t.x));
    var minY = min(tiles.map((t) => t.y));
    var maxX = max(tiles.map((t) => t.x));
    var maxY = max(tiles.map((t) => t.y));
    var lines = [];
    for (int y = minY; y <= maxY; y++) {
      var t = [];
      for (int x = minX; x <= maxX; x++) {
        if (bot.x == x && bot.y == y) {
          t.add('@');
        } else {
          t.add(find(x, y));
        }
      }
      var line = t.join();
      lines.add(line);
    }
    return lines.join('\n');
  }

  int oxygenize(Tile tile) {
    var t = tiles
        .where((t) =>
            (((t.x - tile.x).abs() == 1 && (t.y - tile.y).abs() == 0) ||
                (t.y - tile.y).abs() == 1 && (t.x - tile.x).abs() == 0))
        .map((t) => t.oxygen)
        .where((t) => t != null);
    if (t.isNotEmpty) {
      tile.oxygen = min(t) + 1;
    }
    return tile.oxygen;
  }

  void oxyCheck(Tile t) {
    if (!t.isWall && t.isKnown && t.oxygen == null) {
      var o = oxygenize(t);
      if (o != null) {
        maxOx = max([maxOx, o]);
      }
    }
  }

  Tile find(int x, int y) {
    return tiles.firstWhere((q) => q.x == x && q.y == y,
        orElse: () => Tile(x, y));
  }

  int add(Tile tile) {
    if (tiles.contains(tile)) {
      var t = tiles[tiles.indexOf(tile)];
      return t.dist;
    } else {
      tiles.add(tile);
      var t = tiles.firstWhere(
          (t) =>
              (!t.isWall) &&
              (((t.x - tile.x).abs() == 1 && (t.y - tile.y).abs() == 0) ||
                  (t.y - tile.y).abs() == 1 && (t.x - tile.x).abs() == 0),
          orElse: () => null);
      if (t != null) {
        tile.dist = t.dist + 1;
        return tile.dist;
      }
    }
    return 0;
  }

  void scan() {
    var seen = <int>[];
    for (int i = 0; i < 4; i++) {
      var t = find(bot.nextX(), bot.nextY());
      seen.add(t.isWall ? 999 : t.visited);
      bot.rot();
    }
    var interesting = min(seen);
    for (var i in seen) {
      if (i == interesting) {
        return;
      }
      bot.rot();
    }
  }

  String next() {
    var t = find(bot.nextX(), bot.nextY());
    return t.type;
  }
}

class Tile {
  final int x;
  final int y;
  int dist = 0;
  int oxygen;
  final String type;
  int visited = 0;

  Tile(this.x, this.y, {this.type = ' '});

  operator ==(dynamic t) => t is Tile && t.x == x && t.y == y;
  bool get isWall => type == '#';
  bool get isKnown => type != ' ';

  @override
  String toString() => oxygen != null
      ? visited != null ? visited > 9 ? '░' : visited.toString() : '░'
      : isWall ? '█' : type == '.' ? '.' : type;
}

class Bot {
  int x = 0;
  int y = 0;
  int direction = 1;

  int rot() {
    direction = (direction % 4) + 1;
    return direction;
  }

  int nextX() {
    switch (direction) {
      case 3:
        return x - 1;
      case 4:
        return x + 1;
    }
    return x;
  }

  int nextY() {
    switch (direction) {
      case 1:
        return y - 1;
      case 2:
        return y + 1;
    }
    return y;
  }

  void move() {
    y = nextY();
    x = nextX();
  }
}
