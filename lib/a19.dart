import 'package:adventofcode2019/a.dart';
import 'dart:collection';

import 'package:adventofcode2019/intcode.dart';

class A19 extends A {
  List<String> input;
  int one(List<String> input) {
    this.input = input;
    var output = <Point>[];
    for (int y = 0; y < 50; y++) {
      for (int x = 0; x < 50; x++) {
        if (check(x, y)) {
          output.add(Point(x, y));
        }
      }
    }

    print(output);
    return output.length;
  }

  int two(List<String> input) {
    this.input = input;
    int size = 99;
    int y = 0;
    int x = size;
    while (true) {
      if (check(x, y)) {
        while (true) {
          if (check(x - size, y + size) && check(x, y)) {
            return (x - size) * 10000 + y;
          }
          if (check(x + 1, y)) {
            x++;
          } else {
            break;
          }
        }
        y++;
      } else {
        y++;
      }
    }
  }

  bool check(int x, int y) {
    var codes = IntCode(input);
    codes.addInput([x, y]);
    var o = codes.run();
    if (o != 0) {
      return true;
    }
    return false;
  }
}

class Point {
  final int x;
  final int y;

  Point(this.x, this.y);

  operator ==(dynamic other) => other is Point && other.x == x && other.y == y;

  bool leftOf(Point p) => x < p.x;
  bool rightOf(Point p) => x > p.x;
  bool topOf(Point p) => y < p.y;
  bool bottomOf(Point p) => y > p.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  @override
  String toString() => '$x|$y';
}
