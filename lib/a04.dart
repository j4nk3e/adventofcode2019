import 'package:adventofcode2019/a.dart';

class A04 extends A {
  int one(List<String> input) {
    var pass = input.first.split('-').map((i) => int.parse(i));
    var validCount = 0;
    for (int i = pass.first; i <= pass.last; i++) {
      if (isIncreasing(i) && groupSizes(i).any((i) => i >= 2)) {
        validCount++;
      }
    }
    return validCount;
  }

  int two(List<String> input) {
    var pass = input.first.split('-').map((i) => int.parse(i));
    var validCount = 0;
    for (int i = pass.first; i <= pass.last; i++) {
      if (isIncreasing(i) && groupSizes(i).contains(2)) {
        validCount++;
      }
    }
    return validCount;
  }

  bool isIncreasing(int pass) {
    var prev = 0;
    for (var c in pass.toString().split('')) {
      var i = int.parse(c);
      if (i < prev) {
        return false;
      }
      prev = i;
    }
    return true;
  }

  List<int> groupSizes(int pass) {
    var prev;
    var sizes = <int>[];
    var count = 0;
    for (var c in pass.toString().split('')) {
      if (prev != null && prev != c) {
        sizes.add(count);
        count = 0;
      }
      count++;
      prev = c;
    }
    sizes.add(count);
    return sizes;
  }
}
