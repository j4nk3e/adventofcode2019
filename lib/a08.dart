import 'package:adventofcode2019/a.dart';
import 'package:quiver/iterables.dart';

class A08 extends A {
  static const w = 25;
  static const h = 6;

  List<List<int>> parseImage(List<String> input) {
    final data = input.first.split('').map((i) => int.parse(i)).toList();
    return partition(data, w * h).toList();
  }

  int one(List<String> input) {
    var layers = parseImage(input);
    print('${layers.length} layers');
    var counts = <int>[];
    for (var layer in layers) {
      counts.add(layer.where((i) => i == 0).length);
    }
    MapEntry<int, int> lowestEntry;
    for (var e in counts.asMap().entries) {
      if (lowestEntry == null || lowestEntry.value > e.value) {
        lowestEntry = e;
      }
    }
    print('${lowestEntry.value} zeroes on ${lowestEntry.key}');
    return layers[lowestEntry.key].where((i) => i == 1).length *
        layers[lowestEntry.key].where((i) => i == 2).length;
  }

  int two(List<String> input) {
    var layers = parseImage(input);
    var p = partition(decode(layers), 25).iterator;
    while (p.moveNext()) {
      var line = (p.current.map((i) => i == 0 ? ' ' : 'X')).join();
      print(line);
    }
    return 0;
  }

  Iterable<int> decode(List<List<int>> layers) sync* {
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        yield decodePixel(layers, y * w + x);
      }
    }
  }

  int decodePixel(List<List<int>> layers, int index) {
    for (var layer in layers) {
      if (layer[index] == 0) {
        return 0;
      } else if (layer[index] == 1) {
        return 1;
      }
    }
    return 0;
  }
}
