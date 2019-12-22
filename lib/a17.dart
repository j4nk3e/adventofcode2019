import 'package:adventofcode2019/a.dart';
import 'package:adventofcode2019/intcode.dart';
import 'dart:collection';
import 'dart:math';

import 'package:quiver/iterables.dart';

class A17 extends A {
  var hBars = <Bar>[];
  var vBars = <Bar>[];
  Point bot;

  int one(List<String> input) {
    final codes = IntCode(input);
    List<String> output = [];
    while (true) {
      var o = codes.run();
      if (o == null) {
        break;
      }
      output.add(String.fromCharCode(o));
    }
    var image = output.join('').trim();
    var lines = image.split('\n');
    var points = <Point>[];
    int h = lines.length;
    int w = 0;
    for (var y = 0; y < h; y++) {
      var line = lines[y];
      w = max([w, line.length]);
      for (var x = 0; x < w; x++) {
        if (line[x] == '#') {
          points.add(Point(x, y));
        } else if (line[x] == '^') {
          bot = Point(x, y);
        }
      }
    }
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        Point start;
        var p = Point(x, y);
        if (points.contains(p)) {
          start = p;
          while (points.contains(Point(x + 1, y))) {
            x++;
          }
          if (x - start.x > 1) {
            hBars.add(Bar(start, Point(x, y)));
          }
          start = null;
        }
      }
    }
    for (var x = 0; x < w; x++) {
      for (var y = 0; y < h; y++) {
        Point start;
        var p = Point(x, y);
        if (points.contains(p)) {
          start = p;
          while (points.contains(Point(x, y + 1))) {
            y++;
          }
          if (y - start.y > 1) {
            vBars.add(Bar(start, Point(x, y)));
          }
          start = null;
        }
      }
    }
    var sum = 0;
    for (var hbar in hBars) {
      for (var vbar in vBars) {
        var i = vbar.intersect(hbar);
        if (i != null) {
          lines[i.y] = lines[i.y].replaceRange(i.x, i.x + 1, 'O');
          sum += i.x * i.y;
        }
      }
    }

    for (int y = 0; y < lines.length; y++) {
      print('${lines[y]}');
    }

    return sum;
  }

  int two(List<String> input) {
    one([input[0].replaceRange(0, 1, '1')]);
    final codes = IntCode(input);
    var i = [
      'A,B,C',
      'R,11,L,8,L,4',
      'L,4,L,8',
      'R,6',
      'n\n',
    ];
    while (true) {
      codes.addInput(i?.join('\n')?.codeUnits);
      int o = codes.run();
      if (o != null) {
        print(o);
      }
      i = null;
    }
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

class Bar {
  final Point start;
  final Point end;

  Bar(this.start, this.end) {
    assert((start.x < end.x && start.y == end.y) ||
        (start.y < end.y && start.x == end.x));
  }

  bool get isHorizontal => start.x == end.x;
  bool get isVertical => start.y == end.y;

  Point intersect(Bar o) {
    assert(isVertical && o.isHorizontal);
    if (isHorizontal && o.isVertical) {
      return o.intersect(this);
    } else if (isVertical && o.isHorizontal) {
      if (start.leftOf(o.start) &&
          end.rightOf(o.start) &&
          start.bottomOf(o.start) &&
          start.topOf(o.end)) {
        return Point(o.start.x, start.y);
      }
    }
    return null;
  }

  @override
  String toString() => '$start->$end';
}
