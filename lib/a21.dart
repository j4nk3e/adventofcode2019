import 'package:adventofcode2019/a.dart';
import 'package:adventofcode2019/intcode.dart';

class A21 extends A {
  int one(List<String> input) {
    var code = IntCode(input);
    // always jump if not A B or C
    code.addLine('NOT A J');
    code.addLine('NOT B T');
    code.addLine('OR T J');
    code.addLine('NOT C T');
    code.addLine('OR T J');

    // only jump if D
    code.addLine('AND D J');

    code.addLine('WALK');

    var out = code.runAll();
    print(String.fromCharCodes(out.takeWhile((i) => i < 256)));
    return out.last;
  }

  int two(List<String> input) {
    var code = IntCode(input);
    // always jump if not A B or C
    code.addLine('NOT A J');
    code.addLine('NOT B T');
    code.addLine('OR T J');
    code.addLine('NOT C T');
    code.addLine('OR T J');

    // only jump if D H
    code.addLine('AND D J');
    code.addLine('AND H J');

    // always jump if A
    code.addLine('NOT A T');
    code.addLine('OR T J');

    code.addLine('RUN');

    var out = code.runAll();
    print(String.fromCharCodes(out.takeWhile((i) => i < 256)));
    return out.last;
  }
}
