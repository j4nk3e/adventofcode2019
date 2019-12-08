import 'package:adventofcode2019/a.dart';
import 'package:adventofcode2019/a05.dart';
import 'package:quiver/iterables.dart';
import 'package:trotter/trotter.dart';

class A07 extends A {
  static int run(List<int> codes, List<int> input) {
    var ptr = 0;
    var out = Output();
    var iter = input.iterator;
    final ops = [
      Nop(),
      Add(),
      Multiply(),
      Input(() => (iter..moveNext()).current),
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
    var max = 0;
    for (var l in Permutations(5, Iterable.generate(5).toList()).iterable) {
      var signal = 0;
      for (var i in l) {
        signal = run(List.from(codes), [i, signal]);
      }
      if (signal > max) {
        max = signal;
      }
    }
    return max;
  }

  int two(List<String> input) {
    var codes = readCodes(input);
    var solution = <int>[];
    var configurations = Iterable.generate(5, (i) => 5 + i).toList();
    var amps = configurations.map((c) => Amp(List.of(codes), c));
    for (var l in Permutations(5, amps.toList()).iterable) {
      l.forEach((a) => a.reset());
      print('Permutation $l');
      var max = 0;
      var signal = 0;
      while (signal != null) {
        for (Amp a in l) {
          signal = a.run(signal);
        }
        if (signal != null && signal > max) {
          max = signal;
        }
      }
      print('>>> $max');
      solution.add(max);
    }
    return max(solution);
  }
}

class Amp {
  final List<int> codesOrig;
  var codes;
  final int config;
  var ptr = 0;
  final outOp = Output();
  final List<int> buf;
  Input inOp;

  Amp(this.codesOrig, this.config)
      : codes = List.of(codesOrig),
        buf = [config] {
    inOp = Input(() => buf.removeAt(0));
  }

  int run(int input) {
    if (input != null) {
      buf.add(input);
    }
    final ops = <OpCode>[
      Nop(),
      Add(),
      Multiply(),
      inOp,
      outOp,
      JumpIfTrue(),
      JumpIfFalse(),
      LessThan(),
      Equals(),
    ];
    while (ptr < codes.length) {
      final opCode = codes[ptr] % 100;
      if (opCode == 99) {
        return null;
      } else {
        ptr = ops[opCode].apply(codes, codes[ptr], ptr);
        if (ops[opCode] == outOp) {
          return outOp.output;
        }
      }
    }
    throw Exception('reached end of code');
  }

  @override
  String toString() {
    return config.toString();
  }

  reset() {
    codes = List.of(codesOrig);
    buf.clear();
    buf.add(config);
    outOp.output = null;
    ptr = 0;
  }
}
