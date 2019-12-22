import 'dart:collection';
import 'dart:math';

abstract class OpCode {
  final int argLength;

  OpCode(this.argLength);

  int apply(Map<int, int> codes, int instruction, int ptr, int relativeBase) {
    final args =
        Iterable.generate(argLength, (i) => Param(i, ptr, codes, relativeBase))
            .toList();
    return exec(ptr, args);
  }

  int exec(int ptr, List<Param> args) => ptr + argLength + 1;
}

class Param {
  final int relativeBase;
  final int mode;
  final int index;
  final int ptr;
  final Map<int, int> codes;

  Param(this.index, int ptr, this.codes, this.relativeBase)
      : mode = codes[ptr] ~/ pow(10, index + 2) % 10,
        this.ptr = ptr + index + 1;

  int get addr =>
      (mode == 1) ? ptr : codes[ptr] + ((mode == 2) ? relativeBase : 0);
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

  int base = 0;

  @override
  int exec(int ptr, List<Param> args) {
    base += args.first.value;
    return super.exec(ptr, args);
  }
}

class IntCode {
  final out = Output();
  final relative = Relative();
  final _input = [];
  var ptr = 0;
  Map<int, OpCode> ops;
  Map<int, int> codes;

  IntCode(List<String> input) {
    ops = {
      1: Add(),
      2: Multiply(),
      3: Input(() => _input.removeAt(0)),
      4: out,
      5: JumpIfTrue(),
      6: JumpIfFalse(),
      7: LessThan(),
      8: Equals(),
      9: relative,
    };
    codes = HashMap<int, int>.from(readCodes(input).asMap());
  }

  static List<int> readCodes(List<String> input) =>
      input.join('').split(',').map(int.parse).toList();

  int run([int input]) {
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
        ptr = current.apply(codes, codes[ptr], ptr, relative.base);
      }
      if (out.output != null) {
        return out.output;
      }
    }
  }

  List<int> runAll() {
    var output = <int>[];
    while (true) {
      var o = run();
      if (o == null) {
        return output;
      }
      output.add(o);
    }
  }

  String runString() => String.fromCharCodes(runAll());

  addInput(List<int> input) {
    _input.addAll(input);
  }

  addLine(String line) {
    _input.addAll('$line\n'.codeUnits);
  }

  void clearInput() {
    _input.clear();
  }

  void reset() {
    clearInput();
    ptr = 0;
  }
}
