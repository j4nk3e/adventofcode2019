import 'package:adventofcode2019/a.dart';

class A02 extends A {
  static int run(List<int> codes) {
    final step = 4;
    var ptr = 0;
    final ops = {1: add, 2: multiply};
    while (ptr < codes.length) {
      final instruction = codes[ptr];
      if (instruction == 99) {
        break;
      } else if (ops.containsKey(instruction)) {
        codes[codes[ptr + 3]] =
            ops[instruction](codes[codes[ptr + 1]], codes[codes[ptr + 2]]);
      }
      ptr += step;
    }
    return codes[0];
  }

  static int multiply(int a, int b) => a * b;

  static int add(int a, int b) => a + b;

  int one(List<String> input) {
    final codes = readCodes(input);
    codes[1] = 12;
    codes[2] = 2;
    return run(List.from(codes));
  }

  int two(List<String> input) {
    final codes = readCodes(input);
    for (var noun in Iterable.generate(100)) {
      for (var verb in Iterable.generate(100)) {
        codes[1] = noun;
        codes[2] = verb;
        var solution = run(List.from(codes));
        if (solution == 19690720) {
          return noun * 100 + verb;
        }
      }
    }
    return -1;
  }
}
