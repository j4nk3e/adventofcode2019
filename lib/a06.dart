import 'package:adventofcode2019/a.dart';

class A06 extends A {
  final Orbit root = Orbit('COM', null);
  List<List<String>> orbits;

  List<Orbit> findChildren(Orbit root) {
    var planets = orbits
        .where((o) => o.first == root.id)
        .map((o) => Orbit(o.last, root))
        .toList();
    for (var p in planets) {
      var children = findChildren(p);
      p.children.addAll(children);
    }
    return planets;
  }

  int one(List<String> input) {
    orbits = input.map((o) => o.split(')')).toList();
    root.children.addAll(findChildren(root));
    return root.count;
  }

  int two(List<String> input) {
    orbits = input.map((o) => o.split(')')).toList();
    root.children.addAll(findChildren(root));
    Orbit you = root.find('YOU');
    Orbit san = root.find('SAN');
    var sa = san.ancestors();
    var ma = you.ancestors();
    for (int i = 0; i < sa.length; i++) {
      if (sa[i] != ma[i]) {
        return sa.length + ma.length - 2 * i - 2;
      }
    }
    return -1;
  }
}

class Orbit {
  final String id;
  final int parents;
  final Orbit parent;
  final List<Orbit> children = [];

  Orbit(this.id, this.parent)
      : parents = parent == null ? 0 : parent.parents + 1;

  int get count => children.isEmpty
      ? parents
      : parents + children.map((c) => c.count).reduce((a, b) => a + b);

  List<Orbit> ancestors() {
    return parent == null ? [this] : [...parent.ancestors(), this];
  }

  Orbit find(String id) {
    if (this.id == id) {
      return this;
    }
    return children
        .map((c) => c.find(id))
        .firstWhere((o) => o != null, orElse: () => null);
  }

  operator ==(dynamic o) => o is Orbit && o.id == id;

  @override
  String toString() => id;
}
