import 'package:adventofcode2019/a.dart';

class A16 extends A {
  int one(List<String> input) {
    var numbers = input.first.split('').map((i) => int.parse(i)).toList();
    // var numbers = '80871224585914546619083218645595'
    //     .split('')
    //     .map((i) => int.parse(i))
    //     .toList();
    // var numbers = [1, 2, 3, 4, 5, 6, 7, 8];
    var out = List<int>.from(numbers);
    for (var k = 0; k < 100; k++) {
      print('$k $numbers');
      for (int i = 0; i < out.length; i++) {
        final iter = gen(i).iterator;
        iter.moveNext();
        var sum = 0;
        for (var j in numbers) {
          iter.moveNext();
          sum += j * iter.current;
        }
        out[i] = trunc(sum);
      }
      numbers = out;
    }
    print(numbers);
    return int.parse(numbers.take(8).map((i) => i.toString()).join());
  }

  Iterable<int> gen(int round) sync* {
    List<int> p = pattern(round);
    while (true) {
      for (var i in p) {
        yield i;
      }
    }
  }

  List<int> pattern(int round) => [0, 1, 0, -1]
      .expand((i) => Iterable.generate(round + 1, (_) => i))
      .toList();

  int trunc(int i) => i.abs() % 10;

  int two(List<String> input) {
    return 0;
  }
}
