import 'dart:collection';
import 'dart:convert';
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
  Output out;
  Relative relative;
  final _input = [];
  var ptr = 0;
  Map<int, OpCode> ops;
  final Map<int, int> codes;

  IntCode(this.codes, this.out, this.relative, {int Function() inputFunction}) {
    ops = {
      1: Add(),
      2: Multiply(),
      3: Input(inputFunction ?? () => _input.removeAt(0)),
      4: out,
      5: JumpIfTrue(),
      6: JumpIfFalse(),
      7: LessThan(),
      8: Equals(),
      9: relative,
    };
  }

  factory IntCode.from(List<String> code, {int Function() inputFunction}) =>
      IntCode(
        HashMap<int, int>.from(readCodes(code).asMap()),
        Output(),
        Relative(),
        inputFunction: inputFunction,
      );

  factory IntCode.load(String json) {
    var data = jsonDecode(json);
    return IntCode(
      HashMap<int, int>.from((data['data'] as List).asMap()),
      Output(),
      Relative()..base = data['rel'],
    )..ptr = data['ptr'];
  }

  get memDump =>
      Iterable.generate(codes.keys.last, (i) => codes[i] ?? 0).toList();

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

  Future<int> microtask() async {
    out.output = null;
    final opCode = (codes[ptr]) % 100;
    if (opCode == 99) {
      return null;
    } else {
      final current = ops[opCode];
      ptr = current.apply(codes, codes[ptr], ptr, relative.base);
      if (current is Input) {
        await Future.delayed(Duration(milliseconds: 16));
      }
    }
    return out.output;
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

  OpCode instruction;

  String runUntilIO([String input]) {
    var output = <int>[];
    while (true) {
      if (input != null) {
        _input.addAll('$input\n'.codeUnits);
      }
      while (true) {
        final opCode = (codes[ptr]) % 100;
        if (opCode == 99) {
          instruction = null;
          break;
        } else {
          instruction = ops[opCode];
          if (instruction is Input && _input.isEmpty) {
            break;
          }
          ptr = instruction.apply(codes, codes[ptr], ptr, relative.base);
        }
        if (out.output != null) {
          output.add(out.output);
          var char = String.fromCharCode(out.output);
          out.output = null;
          if (char == '\n') {
            break;
          }
        }
      }
      return String.fromCharCodes(output);
    }
  }

  IntCode copy() => IntCode(Map.from(codes), Output()..output = out.output,
      Relative()..base = relative.base)
    ..ptr = ptr;

  String runString() {
    var all = runAll();
    var str = String.fromCharCodes(all.where(((i) => i < 256)));
    var rest = all.where(((i) => i >= 256)).toString();
    return '$str\n$rest';
  }

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

  String toJson() =>
      jsonEncode({'ptr': ptr, 'rel': relative.base, 'data': memDump});
}
