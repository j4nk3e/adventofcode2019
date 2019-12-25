import 'dart:math';

import 'package:adventofcode2019/intcode.dart';
import 'package:quiver/iterables.dart';
import 'package:adventofcode2019/a.dart';

class A11 extends A {
  int one(List<String> input) {
    final codes = IntCode.from(input);
    var panel = [Panel(0, 0)];
    var robot = Robot();
    while (true) {
      final p =
          panel.firstWhere((p) => robot.x == p.x && robot.y == p.y, orElse: () {
        var p = Panel(robot.x, robot.y);
        panel.add(p);
        return p;
      });
      var color = codes.run(p.color);
      if (color != null) {
        p.color = color;
      } else {
        break;
      }
      var direction = codes.run();
      if (direction != null) {
        direction == 0 ? robot.left() : robot.right();
      } else {
        break;
      }
    }
    return panel.length;
  }

  int two(List<String> input) {
    final codes = IntCode.from(input);
    var panel = [Panel(0, 0)..color = 1];
    var robot = Robot();
    while (true) {
      final p =
          panel.firstWhere((p) => robot.x == p.x && robot.y == p.y, orElse: () {
        var p = Panel(robot.x, robot.y);
        panel.add(p);
        return p;
      });
      var color = codes.run(p.color);
      if (color != null) {
        p.color = color;
      } else {
        break;
      }
      var direction = codes.run();
      if (direction != null) {
        direction == 0 ? robot.left() : robot.right();
      } else {
        break;
      }
    }
    printPanels(panel.where((p) => p.color == 1).toList());
    return panel.length;
  }

  printPanels(List<Panel> l) {
    var minx = min(l.map((p) => p.x));
    var miny = min(l.map((p) => p.y));
    var maxx = max(l.map((p) => p.x));
    var maxy = max(l.map((p) => p.y));
    var w = maxx - minx;
    var h = maxy - miny;
    List<List<String>> out = Iterable.generate(h + 1, (i) {
      return Iterable.generate(w + 1, (j) => ' ').toList();
    }).toList();
    for (var p in l) {
      out[p.y - miny][p.x - minx] = '█';
    }
    for (var line in out) {
      print(line.join());
    }
  }
}

class Robot {
  int x = 0;
  int y = 0;
  int direction = 0;

  Panel left() {
    direction = (direction + 3) % 4;
    return _move();
  }

  Panel right() {
    direction = (direction + 1) % 4;
    return _move();
  }

  Panel _move() {
    switch (direction) {
      case 0:
        y--;
        break;
      case 1:
        x++;
        break;
      case 2:
        y++;
        break;
      case 3:
        x--;
        break;
    }
    return Panel(x, y);
  }
}

class Panel {
  final int x;
  final int y;
  int color = 0;

  Panel(this.x, this.y);

  operator ==(o) => o is Panel && o.x == x && o.y == y;

  @override
  String toString() => 'P($x|$y)$color';
}
