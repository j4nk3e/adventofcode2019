import 'dart:math';

import 'package:adventofcode2019/a.dart';

class A24 extends A {
  int one(List<String> input) {
    var generations = Set<int>();
    int i = 0;
    var field = input
        .map((line) => line.split('').map((c) => c == '#').toList())
        .toList();
    while (true) {
      var c = count(field);
      printField(field);
      print('$i => $c\n');
      i++;
      field = next(field);
      generations.add(c);
      if (generations.length < i) {
        return c;
      }
    }
  }

  int count(List<List<bool>> field) {
    var sum = 0;
    var i = 0;
    for (int y = 0; y < field.length; y++) {
      for (int x = 0; x < field.length; x++) {
        sum += field[y][x] ? pow(2, i) : 0;
        i++;
      }
    }
    return sum;
  }

  List<List<bool>> next(List<List<bool>> field) {
    var nextGen =
        List.generate(field.length, (i) => List.filled(field[0].length, false));
    for (int y = 0; y < field.length; y++) {
      var row = field[y];
      for (int x = 0; x < row.length; x++) {
        var sum = 0;
        sum += x > 0 && row[x - 1] ? 1 : 0;
        sum += x < row.length - 1 && row[x + 1] ? 1 : 0;
        sum += y > 0 && field[y - 1][x] ? 1 : 0;
        sum += y < field.length - 1 && field[y + 1][x] ? 1 : 0;
        nextGen[y][x] = row[x] ? sum == 1 : sum > 0 && sum < 3;
      }
    }
    return nextGen;
  }

  void printField(List<List<bool>> field) {
    for (var row in field) {
      print(row.map((c) => c ? '#' : '.').join());
    }
  }

  int two(List<String> input) {
    var field = input
        .map((line) => line.split('').map((c) => c == '#').toList())
        .toList();
    var f = Field(field);
    for (var i in Iterable.generate(200)) {
      print('$i: ${f.count} (${f.depth} layers)');
      f = f.next();
    }
    return f.count;
  }
}

class Field {
  List<List<bool>> field;
  Field parent;
  Field child;

  Field(this.field);

  factory Field.empty(int len) =>
      Field(List.generate(len, (i) => List.filled(len, false)));

  int get depth => child == null ? 1 : 1 + child.depth;
  int get count =>
      field
          .map((row) => row.map((c) => c ? 1 : 0))
          .expand((q) => q)
          .reduce((a, b) => a + b) +
      (child?.count ?? 0);

  int get ol => field.map((r) => r.first ? 1 : 0).reduce((a, b) => a + b);
  int get or => field.map((r) => r.last ? 1 : 0).reduce((a, b) => a + b);
  int get ot => field.first.map((c) => c ? 1 : 0).reduce((a, b) => a + b);
  int get ob => field.last.map((c) => c ? 1 : 0).reduce((a, b) => a + b);

  bool get il => field[2][1];
  bool get ir => field[2][3];
  bool get it => field[1][2];
  bool get ib => field[3][2];

  Field next() {
    var nextGen =
        List.generate(field.length, (i) => List.filled(field[0].length, false));
    for (int y = 0; y < field.length; y++) {
      var row = field[y];
      for (int x = 0; x < row.length; x++) {
        var sum = 0;
        sum += (x > 0 ? row[x - 1] : (parent?.il ?? false))
            ? 1
            : (x == 3 && y == 2) ? (child?.or ?? 0) : 0;
        sum += (x < row.length - 1 ? row[x + 1] : (parent?.ir ?? false))
            ? 1
            : (x == 1 && y == 2) ? (child?.ol ?? 0) : 0;

        sum += (y > 0 ? field[y - 1][x] : (parent?.it ?? false))
            ? 1
            : (x == 2 && y == 3) ? (child?.ob ?? 0) : 0;

        sum += (y < field.length - 1 ? field[y + 1][x] : (parent?.ib ?? false))
            ? 1
            : (x == 2 && y == 1) ? (child?.ot ?? 0) : 0;

        if (x == 2 && y == 2) {
          if (child == null && sum > 0) {
            child = Field.empty(field.length);
            child.parent = this;
          }
        } else {
          nextGen[y][x] = row[x] ? sum == 1 : sum > 0 && sum < 3;
        }
      }
    }
    var outer = [ol, ot, or, ob];
    if (parent == null && outer.any((c) => c > 0 && c < 3)) {
      parent = Field.empty(field.length);
      parent.field[2][1] = outer[0] > 0 && outer[0] < 3;
      parent.field[1][2] = outer[1] > 0 && outer[1] < 3;
      parent.field[2][3] = outer[2] > 0 && outer[2] < 3;
      parent.field[3][2] = outer[3] > 0 && outer[3] < 3;
      parent.child = this;
    }
    if (child != null) {
      child.next();
    }
    field = nextGen;
    return parent == null ? this : parent;
  }

  @override
  String toString() {
    var out = ['Depth $depth'];
    for (var row in field) {
      out.add(row.map((c) => c ? '#' : '.').join());
    }
    if (child != null) {
      out.add('\n${child.toString()}');
    }
    return out.join('\n');
  }
}
