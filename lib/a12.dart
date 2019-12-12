import 'dart:math';

import 'package:adventofcode2019/a.dart';

class A12 extends A {
  int one(List<String> input) {
    var j = Ju.from(input);
    var energy = 0;
    for (var _ in Iterable.generate(1000)) {
      energy = j.step();
    }
    return energy;
  }

  int ggt(int m, int n) {
    if (n == 0) {
      return m;
    } else {
      return ggt(n, m % n);
    }
  }

  int kgv(int m, int n) => (m * n) ~/ ggt(m, n);

  int two(List<String> input) {
    var j = Ju.from(input);
    var x = Set<String>();
    int i = 0;
    int c = 0;
    var sol = <int>[];
    for (var a = 0; a < 3; a++) {
      while (true) {
        i++;
        j.step();
        var str =
            j.moons.map((m) => '${m.position[a]} ${m.speed[a]}').join('|');
        if (x.contains(str)) {
          if (c == 0) {
            c = i;
            x.clear();
          } else {
            sol.add(i - c);
            c = 0;
            x.clear();
            break;
          }
        }
        x.add(str);
      }
    }
    print(sol);
    return kgv(kgv(sol[0], sol[1]), sol[2]);
  }
}

class Ju {
  List<Moon> moons;

  Ju(this.moons);

  factory Ju.from(List<String> input) => Ju(input.map((l) {
        var coords = l
            .substring(1, l.length - 1)
            .split(', ')
            .map((c) => int.parse(c.split('=').last))
            .toList();
        return Moon.from(coords[0], coords[1], coords[2]);
      }).toList());

  int step() {
    for (var moon in moons) {
      moons.forEach((m) => moon.gravity(m));
    }
    for (var moon in moons) {
      moon.move();
    }
    return energy;
  }

  int get energy => moons.map((m) => m.energy).reduce((a, b) => a + b);

  Ju copy() => Ju(moons.map((m) => m.copy()).toList());

  operator ==(dynamic o) =>
      o is Ju &&
      o.moons.length == moons.length &&
      Iterable.generate(o.moons.length, (i) => o.moons[i] == moons[i])
          .every((m) => m);

  @override
  String toString() => moons.map((m) => m.toString()).join(', ');
}

class Moon {
  V3 position = V3.zero();
  V3 speed = V3.zero();

  int count = 0;
  V3 resetP;
  V3 resetS = V3.zero();

  Moon(this.position, this.speed) : resetP = position;

  factory Moon.from(int x, int y, int z) => Moon(V3(x, y, z), V3.zero());

  Moon copy() => Moon(position, speed);

  void gravity(Moon b) => speed += (b.position - position).sign;

  void move() => position += speed;

  int get energy => position.abs * speed.abs;

  operator ==(dynamic o) =>
      o is Moon && o.position == position && o.speed == speed;

  @override
  int get hashCode => position.hashCode * 1000000000 ^ speed.hashCode;

  @override
  String toString() => 'pos=$position, vel=$speed';
}

class V3 {
  final int x;
  final int y;
  final int z;

  V3(this.x, this.y, this.z);

  factory V3.zero() => V3(0, 0, 0);

  operator +(V3 b) => V3(x + b.x, y + b.y, z + b.z);

  operator -(V3 b) => V3(x - b.x, y - b.y, z - b.z);

  operator ==(dynamic o) => o is V3 && o.x == x && o.y == y && o.z == z;

  @override
  int get hashCode => x.hashCode * 1000000 ^ y.hashCode * 1000 ^ z.hashCode;

  V3 get sign => V3(x.sign, y.sign, z.sign);

  int get abs => x.abs() + y.abs() + z.abs();

  operator [](int i) => i == 0 ? x : i == 1 ? y : z;

  V3 min(V3 o) {
    if (o.x < x) {
      return o;
    } else if (o.x == x) {
      if (o.y < y) {
        return o;
      } else if (o.y == y) {
        return o.z < z ? o : this;
      }
      return this;
    }
    return this;
  }

  V3 max(V3 o) {
    if (o.x > x) {
      return o;
    } else if (o.x == x) {
      if (o.y > y) {
        return o;
      } else if (o.y == y) {
        return o.z > z ? o : this;
      }
      return this;
    }
    return this;
  }

  @override
  String toString() => '($x|$y|$z)';
}
