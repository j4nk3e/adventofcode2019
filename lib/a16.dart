import 'dart:math';

import 'package:adventofcode2019/a.dart';

class A16 extends A {
  int one(List<String> input) {
    var n = input.first.split('').map((i) => int.parse(i)).toList();
    var numbers = n;
    for (var k = 0; k < 100; k++) {
      print(k);
      var prev = 0;
      for (int i = 0; i < numbers.length / 2; i++) {
        var step = i + 1;
        var mult = 1;
        var sum = 0;
        for (var n = i; n < numbers.length; n += step * 2) {
          sum += numbers.skip(n).take(step).reduce((a, b) => a + b) * mult;
          mult *= -1;
        }
        numbers[i] = trunc(sum);
      }
      for (int i = numbers.length - 1; i >= numbers.length ~/ 2; i--) {
        prev = (prev + numbers[i]) % 10;
        numbers[i] = prev;
      }
    }
    return int.parse(numbers.take(8).map((i) => i.toString()).join());
  }

  int trunc(int i) => i.abs() % 10;

  int two(List<String> input) {
    var n = input.first.split('').map((i) => int.parse(i)).toList();
    var pos = int.parse(n.take(7).map((i) => i.toString()).join(''));
    var numbers = Iterable.generate(10000, (_) => n).expand((i) => i).toList();
    for (var k = 0; k < 100; k++) {
      print(k);
      var prev = 0;
      for (int i = pos; i < numbers.length / 2; i++) {
        var step = i + 1;
        var mult = 1;
        var sum = 0;
        for (var n = i; n < numbers.length; n += step * 2) {
          sum += numbers.skip(n).take(step).reduce((a, b) => a + b) * mult;
          mult *= -1;
        }
        numbers[i] = trunc(sum);
      }
      for (int i = numbers.length - 1;
          i >= max(numbers.length ~/ 2, pos);
          i--) {
        prev = (prev + numbers[i]) % 10;
        numbers[i] = prev;
      }
    }
    return int.parse(numbers.skip(pos).take(8).map((i) => i.toString()).join());
  }
}
