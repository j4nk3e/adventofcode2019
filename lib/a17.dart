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

class A17 extends A {
  A17() {
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

  int run(Map<int, int> codes, [List<int> input]) {
    if (input != null) {
      _input.addAll(input);
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

  var hBars = <Bar>[];
  var vBars = <Bar>[];
  Point bot;

  int one(List<String> input) {
    final codes = readCodes(input);
    Map<int, int> map = HashMap.from(codes.asMap());
    List<String> output = [];
    while (true) {
      var o = run(map);
      if (o == null) {
        break;
      }
      output.add(String.fromCharCode(o));
    }
    var image = output.join('').trim();
    var lines = image.split('\n');
    var points = <Point>[];
    int h = lines.length;
    int w = 0;
    for (var y = 0; y < h; y++) {
      var line = lines[y];
      w = max([w, line.length]);
      for (var x = 0; x < w; x++) {
        if (line[x] == '#') {
          points.add(Point(x, y));
        } else if (line[x] == '^') {
          bot = Point(x, y);
        }
      }
    }
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        Point start;
        var p = Point(x, y);
        if (points.contains(p)) {
          start = p;
          while (points.contains(Point(x + 1, y))) {
            x++;
          }
          if (x - start.x > 1) {
            hBars.add(Bar(start, Point(x, y)));
          }
          start = null;
        }
      }
    }
    for (var x = 0; x < w; x++) {
      for (var y = 0; y < h; y++) {
        Point start;
        var p = Point(x, y);
        if (points.contains(p)) {
          start = p;
          while (points.contains(Point(x, y + 1))) {
            y++;
          }
          if (y - start.y > 1) {
            vBars.add(Bar(start, Point(x, y)));
          }
          start = null;
        }
      }
    }
    var sum = 0;
    for (var hbar in hBars) {
      for (var vbar in vBars) {
        var i = vbar.intersect(hbar);
        if (i != null) {
          lines[i.y] = lines[i.y].replaceRange(i.x, i.x + 1, 'O');
          sum += i.x * i.y;
        }
      }
    }

    for (int y = 0; y < lines.length; y++) {
      print('${lines[y]}');
    }

    return sum;
  }

  int two(List<String> input) {
    one([input[0].replaceRange(0, 1, '1')]);
    final codes = readCodes(input);
    Map<int, int> map = HashMap.from(codes.asMap());
    var i = [
      'A,B,C',
      'R,11,L,8,L,4',
      'L,4,L,8',
      'R,6',
      'n\n',
    ];
    while (true) {
      int o = run(map, i?.join('\n')?.codeUnits);
      if (o != null) {
        print(o);
      }
      i = null;
    }
  }
}

class Point {
  final int x;
  final int y;

  Point(this.x, this.y);

  operator ==(dynamic other) => other is Point && other.x == x && other.y == y;

  bool leftOf(Point p) => x < p.x;
  bool rightOf(Point p) => x > p.x;
  bool topOf(Point p) => y < p.y;
  bool bottomOf(Point p) => y > p.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  @override
  String toString() => '$x|$y';
}

class Bar {
  final Point start;
  final Point end;

  Bar(this.start, this.end) {
    assert((start.x < end.x && start.y == end.y) ||
        (start.y < end.y && start.x == end.x));
  }

  bool get isHorizontal => start.x == end.x;
  bool get isVertical => start.y == end.y;

  Point intersect(Bar o) {
    assert(isVertical && o.isHorizontal);
    if (isHorizontal && o.isVertical) {
      return o.intersect(this);
    } else if (isVertical && o.isHorizontal) {
      if (start.leftOf(o.start) &&
          end.rightOf(o.start) &&
          start.bottomOf(o.start) &&
          start.topOf(o.end)) {
        return Point(o.start.x, start.y);
      }
    }
    return null;
  }

  @override
  String toString() => '$start->$end';
}
