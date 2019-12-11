import 'dart:collection';
import 'dart:math';

import 'package:quiver/iterables.dart';
import 'package:adventofcode2019/a.dart';

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
  int get value => codes.containsKey(addr)
      ? codes[addr]
      : 0; //throw Exception('read from uninitialized memory $addr');
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

  List<int> output = [];

  @override
  int exec(int ptr, List<Param> args) {
    output.add(args[0].value);
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

class A11 extends A {
  A11() {
    Relative.base = 0;
    ops = {
      1: Add(),
      2: Multiply(),
      3: Input(() => _input),
      4: out,
      5: JumpIfTrue(),
      6: JumpIfFalse(),
      7: LessThan(),
      8: Equals(),
      9: Relative(),
    };
  }
  var out = Output();
  var _input = 0;
  var ptr = 0;
  var ops;

  int run(Map<int, int> codes, [int input]) {
    if (input != null) {
      _input = input;
    }
    while (true) {
      final opCode = (codes[ptr]) % 100;
      if (opCode == 99) {
        return null;
      } else {
        final current = ops[opCode];
        ptr = current.apply(codes, codes[ptr], ptr);
        if (current == out) {
          return out.output.last;
        }
      }
    }
  }

  int one(List<String> input) {
    final codes = readCodes(input);
    Map<int, int> map = HashMap.from(codes.asMap());
    var panel = [Panel(0, 0)];
    var robot = Robot();
    while (true) {
      final p =
          panel.firstWhere((p) => robot.x == p.x && robot.y == p.y, orElse: () {
        var p = Panel(robot.x, robot.y);
        panel.add(p);
        return p;
      });
      var color = run(map, p.color);
      if (color != null) {
        p.color = color;
      } else {
        break;
      }
      var direction = run(map);
      if (direction != null) {
        direction == 0 ? robot.left() : robot.right();
      } else {
        break;
      }
    }
    return panel.length;
  }

  int two(List<String> input) {
    final codes = readCodes(input);
    Map<int, int> map = HashMap.from(codes.asMap());
    var panel = [Panel(0, 0)..color = 1];
    var robot = Robot();
    while (true) {
      final p =
          panel.firstWhere((p) => robot.x == p.x && robot.y == p.y, orElse: () {
        var p = Panel(robot.x, robot.y);
        panel.add(p);
        return p;
      });
      var color = run(map, p.color);
      if (color != null) {
        p.color = color;
      } else {
        break;
      }
      var direction = run(map);
      if (direction != null) {
        direction == 0 ? robot.left() : robot.right();
      } else {
        break;
      }
    }
    printPanels(panel.where((p) => p.color == 1).toList());
    return panel.length;
  }

  printPanels(List<Panel> l) {
    var minx = min(l.map((p) => p.x));
    var miny = min(l.map((p) => p.y));
    var maxx = max(l.map((p) => p.x));
    var maxy = max(l.map((p) => p.y));
    var w = maxx - minx;
    var h = maxy - miny;
    List<List<String>> out = Iterable.generate(h + 1, (i) {
      return Iterable.generate(w + 1, (j) => ' ').toList();
    }).toList();
    for (var p in l) {
      out[p.y - miny][p.x - minx] = '█';
    }
    for (var line in out) {
      print(line.join());
    }
  }
}

class Robot {
  int x = 0;
  int y = 0;
  int direction = 0;

  Panel left() {
    direction = (direction + 3) % 4;
    return _move();
  }

  Panel right() {
    direction = (direction + 1) % 4;
    return _move();
  }

  Panel _move() {
    switch (direction) {
      case 0:
        y--;
        break;
      case 1:
        x++;
        break;
      case 2:
        y++;
        break;
      case 3:
        x--;
        break;
    }
    return Panel(x, y);
  }
}

class Panel {
  final int x;
  final int y;
  int color = 0;

  Panel(this.x, this.y);

  operator ==(o) => o is Panel && o.x == x && o.y == y;

  @override
  String toString() => 'P($x|$y)$color';
}
