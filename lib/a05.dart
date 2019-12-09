import 'package:adventofcode2019/a.dart';

abstract class OpCode {
  final int argLength;

  OpCode(this.argLength);

  int apply(List<int> codes, int instruction, int ptr) {
    final positional = _modes(instruction);
    final args = Iterable.generate(argLength,
        (i) => _resolve(positional[i], codes[ptr + i + 1], codes)).toList();
    return exec(codes, args, ptr);
  }

  int exec(List<int> codes, List<int> args, int ptr);

  int _resolve(int mode, int param, List<int> codes) =>
      (mode == 0) ? codes[param] : param;

  List<int> _modes(int instruction) => [
        (instruction / 100 % 10).toInt(),
        (instruction / 1000 % 10).toInt(),
        (instruction / 10000 % 10).toInt(),
      ];
}

class Nop extends OpCode {
  Nop() : super(0);

  @override
  int exec(List<int> codes, List<int> args, int ptr) => null;
}

class Add extends OpCode {
  Add() : super(2);

  @override
  int exec(List<int> codes, List<int> args, int ptr) {
    codes[codes[ptr + 3]] = args[0] + args[1];
    return ptr + 4;
  }
}

class Multiply extends OpCode {
  Multiply() : super(2);

  @override
  int exec(List<int> codes, List<int> args, int ptr) {
    codes[codes[ptr + 3]] = args[0] * args[1];
    return ptr + 4;
  }
}

class Input extends OpCode {
  final int Function() input;

  Input(this.input) : super(0);

  @override
  int exec(List<int> codes, List<int> args, int ptr) {
    codes[codes[ptr + 1]] = input();
    return ptr + 2;
  }
}

class Output extends OpCode {
  Output() : super(1);

  int output;

  @override
  int exec(List<int> codes, List<int> args, int ptr) {
    output = args[0];
    return ptr + 2;
  }
}

class JumpIfTrue extends OpCode {
  JumpIfTrue() : super(2);

  @override
  int exec(List<int> codes, List<int> args, int ptr) =>
      args[0] != 0 ? args[1] : ptr + 3;
}

class JumpIfFalse extends OpCode {
  JumpIfFalse() : super(2);

  @override
  int exec(List<int> codes, List<int> args, int ptr) =>
      args[0] == 0 ? args[1] : ptr + 3;
}

class LessThan extends OpCode {
  LessThan() : super(2);

  @override
  int exec(List<int> codes, List<int> args, int ptr) {
    codes[codes[ptr + 3]] = args[0] < args[1] ? 1 : 0;
    return ptr + 4;
  }
}

class Equals extends OpCode {
  Equals() : super(2);

  @override
  int exec(List<int> codes, List<int> args, int ptr) {
    codes[codes[ptr + 3]] = args[0] == args[1] ? 1 : 0;
    return ptr + 4;
  }
}

class A05 extends A {
  var out = Output();
  int run(List<int> codes, int input) {
    var ptr = 0;
    final ops = [
      Nop(),
      Add(),
      Multiply(),
      Input(() => input),
      out,
      JumpIfTrue(),
      JumpIfFalse(),
      LessThan(),
      Equals(),
    ];
    while (ptr < codes.length) {
      final opCode = codes[ptr] % 100;
      if (opCode == 99) {
        break;
      } else {
        print('$ptr > ${ops[opCode].runtimeType}');
        ptr = ops[opCode].apply(codes, codes[ptr], ptr);
      }
    }
    return out.output;
  }

  int one(List<String> input) {
    final codes = readCodes(input);
    return run(List.from(codes), 1);
  }

  int two(List<String> input) {
    final codes = readCodes(input);
    return run(List.from(codes), 5);
  }
}
