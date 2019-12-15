import 'package:adventofcode2019/a.dart';
import 'dart:collection';
import 'dart:math';

import 'package:quiver/iterables.dart';

abstract class OpCode {
  final int argLength;

  OpCode(this.argLength);

  int apply(Map<int, int> codes, int instruction, int ptr) {
    final args =
        Iterable.generate(argLength, (i) => Param(i, ptr, codes)).toList();
    return exec(ptr, args);
  }

  int exec(int ptr, List<Param> args) => ptr + argLength + 1;
}

class Param {
  final int mode;
  final int index;
  final int ptr;
  final Map<int, int> codes;

  Param(this.index, int ptr, this.codes)
      : mode = codes[ptr] ~/ pow(10, index + 2) % 10,
        this.ptr = ptr + index + 1;

  int get addr =>
      (mode == 1) ? ptr : codes[ptr] + ((mode == 2) ? Relative.base : 0);
  int get value => codes.containsKey(addr) ? codes[addr] : 0;
  set value(int v) =>
      (mode == 1) ? throw Exception('immediate write') : codes[addr] = v;
}

class Add extends OpCode {
  Add() : super(3);

  @override
  int exec(int ptr, List<Param> args) {
    args[2].value = args[0].value + args[1].value;
    return super.exec(ptr, args);
  }
}

class Multiply extends OpCode {
  Multiply() : super(3);

  @override
  int exec(int ptr, List<Param> args) {
    args.last.value = args[0].value * args[1].value;
    return super.exec(ptr, args);
  }
}

class Input extends OpCode {
  final int Function() input;

  Input(this.input) : super(1);

  @override
  int exec(int ptr, List<Param> args) {
    args.last.value = input();
    return super.exec(ptr, args);
  }
}

class Output extends OpCode {
  Output() : super(1);

  int output;

  @override
  int exec(int ptr, List<Param> args) {
    output = args[0].value;
    return super.exec(ptr, args);
  }
}

class JumpIfTrue extends OpCode {
  JumpIfTrue() : super(2);

  @override
  int exec(int ptr, List<Param> args) =>
      args[0].value != 0 ? args[1].value : super.exec(ptr, args);
}

class JumpIfFalse extends OpCode {
  JumpIfFalse() : super(2);

  @override
  int exec(int ptr, List<Param> args) =>
      args[0].value == 0 ? args[1].value : super.exec(ptr, args);
}

class LessThan extends OpCode {
  LessThan() : super(3);

  @override
  int exec(int ptr, List<Param> args) {
    args.last.value = args[0].value < args[1].value ? 1 : 0;
    return super.exec(ptr, args);
  }
}

class Equals extends OpCode {
  Equals() : super(3);

  @override
  int exec(int ptr, List<Param> args) {
    args.last.value = args[0].value == args[1].value ? 1 : 0;
    return super.exec(ptr, args);
  }
}

class Relative extends OpCode {
  Relative() : super(1);

  static int base = 0;

  @override
  int exec(int ptr, List<Param> args) {
    base += args.first.value;
    return super.exec(ptr, args);
  }
}

class A15 extends A {
  A15() {
    Relative.base = 0;
    ops = {
      1: Add(),
      2: Multiply(),
      3: Input(() => _input.removeAt(0)),
      4: out,
      5: JumpIfTrue(),
      6: JumpIfFalse(),
      7: LessThan(),
      8: Equals(),
      9: Relative(),
    };
  }
  var out = Output();
  var _input = [];
  var ptr = 0;
  var ops;

  int run(Map<int, int> codes, [int input]) {
    if (input != null) {
      _input.add(input);
    }
    out.output = null;
    while (true) {
      final opCode = (codes[ptr]) % 100;
      if (opCode == 99) {
        return null;
      } else {
        final current = ops[opCode];
        ptr = current.apply(codes, codes[ptr], ptr);
      }
      if (out.output != null) {
        return out.output;
      }
    }
  }

  int one(List<String> input) {
    final codes = readCodes(input);
    Map<int, int> map = HashMap.from(codes.asMap());
    Ship ship = Ship();
    ship.tiles.add(Tile(0, 0, type: 'X'));
    for (int i = 0; true; i++) {
      var o = run(map, ship.bot.direction);
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
    final codes = readCodes(input);
    Map<int, int> map = HashMap.from(codes.asMap());
    Ship ship = Ship();
    ship.tiles.add(Tile(0, 0, type: 'X'));
    for (int i = 0; true; i++) {
      var o = run(map, ship.bot.direction);
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
