import 'dart:collection';
import 'dart:math';

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
      : throw Exception('read from uninitialized memory');
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

class A09 extends A {
  var out = Output();
  int run(Map<int, int> codes, int input) {
    Relative.base = 0;
    var ptr = 0;
    final ops = {
      1: Add(),
      2: Multiply(),
      3: Input(() => input),
      4: out,
      5: JumpIfTrue(),
      6: JumpIfFalse(),
      7: LessThan(),
      8: Equals(),
      9: Relative(),
    };
    while (true) {
      final opCode = (codes[ptr]) % 100;
      if (opCode == 99) {
        break;
      } else {
        ptr = ops[opCode].apply(codes, codes[ptr], ptr);
      }
    }
    print('Output: ${out.output}');
    return out.output.last;
  }

  int one(List<String> input) {
    final codes = readCodes(input);
    Map<int, int> map = HashMap.from(codes.asMap());
    return run(map, 1);
  }

  int two(List<String> input) {
    final codes = readCodes(input);
    Map<int, int> map = HashMap.from(codes.asMap());
    return run(map, 2);
  }
}
