import 'package:adventofcode2019/a.dart';
import 'package:adventofcode2019/intcode.dart';

class A09 extends A {
  int one(List<String> input) {
    return IntCode(input).run(1);
  }

  int two(List<String> input) {
    return IntCode(input).run(2);
  }
}
