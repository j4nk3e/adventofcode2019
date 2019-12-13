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

class A13 extends A {
  A13() {
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
    _input = input ?? 0;
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
    var scr = <int>[];
    while (true) {
      var o = run(map);
      if (o == null) {
        break;
      }
      scr.add(o);
    }
    return partition(scr, 3).where((i) => i.last == 2).length;
  }

  int two(List<String> input) {
    final codes = readCodes(input);
    Map<int, int> map = HashMap.from(codes.asMap());
    var s = <int>[];
    var paddle = 0;
    var ball = 0;
    var score = 0;
    var blocks = 0;
    while (true) {
      var o = run(map, (ball - paddle).sign);
      if (o == null) {
        break;
      }
      s.add(o);
      if (s.length == 3) {
        if (s.first == -1) {
          score = s.last;
          print('Score: $score / Blocks: $blocks');
          blocks = 0;
        } else if (s.last == 3) {
          paddle = s[0];
          print('Paddle: $paddle');
        } else if (s.last == 4) {
          ball = s[0];
          print('Ball: >>> ${s[0]}|${s[1]}');
        } else if (s.last == 2) {
          blocks++;
        }
        s.clear();
      }
    }
    return score;
  }
}
