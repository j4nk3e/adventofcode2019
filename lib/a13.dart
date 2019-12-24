import 'package:adventofcode2019/a.dart';
import 'dart:collection';
import 'dart:math';

import 'package:quiver/iterables.dart';

import 'intcode.dart';

class A13 extends A {
  int one(List<String> input) {
    final codes = IntCode(input);
    var scr = <int>[];
    while (true) {
      var o = codes.run();
      if (o == null) {
        break;
      }
      scr.add(o);
    }
    return partition(scr, 3).where((i) => i.last == 2).length;
  }

  int two(List<String> input) {
    final codes = IntCode(input);
    var s = <int>[];
    var paddle = 0;
    var ball = 0;
    var score = 0;
    var blocks = 0;
    while (true) {
      codes.clearInput();
      var o = codes.run((ball - paddle).sign);
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
