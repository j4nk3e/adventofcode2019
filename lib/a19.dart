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

class A19 extends A {
  A19() {
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

  int one(List<String> input) {
    codes = readCodes(input);
    var output = <Point>[];
    for (int y = 0; y < 50; y++) {
      for (int x = 0; x < 50; x++) {
        if (check(x, y)) {
          output.add(Point(x, y));
        }
      }
    }

    print(output);
    return output.length;
  }

  var codes;

  int two(List<String> input) {
    codes = readCodes(input);
    int size = 99;
    int y = 0;
    int x = size;
    while (true) {
      if (check(x, y)) {
        while (true) {
          if (check(x - size, y + size) && check(x, y)) {
            return (x - size) * 10000 + y;
          }
          if (check(x + 1, y)) {
            x++;
          } else {
            break;
          }
        }
        y++;
      } else {
        y++;
      }
    }
  }

  bool check(int x, int y) {
    Map<int, int> map = HashMap.from(codes.asMap());
    Relative.base = 0;
    ptr = 0;
    _input.clear();
    var o = run(map, [x, y]);
    if (o != 0) {
      return true;
    }
    return false;
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
