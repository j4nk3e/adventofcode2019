import 'package:adventofcode2019/a.dart';

class A14 extends A {
  int one(List<String> input) {
    var reactions = input.map((l) {
      var s = l.split(' => ');
      var i = s.first.split(', ').map((c) => Chem.from(c));
      var c = Chem.from(s.last);
      c.input = Map.fromEntries(i.map((i) => MapEntry(i.id, i.output)));
      return c;
    });
    Chem fuel = reactions.firstWhere((c) => c.id == 'FUEL');
    var re = fuel.input;
    re['ORE'] = re['ORE'] ?? 0;
    var pool = <String, int>{};
    while (true) {
      if (re.length == 1 && re.keys.first == 'ORE') {
        print(pool);
        return re.values.first;
      }
      var replace = re.entries.firstWhere((i) => i.key != 'ORE');
      var c = reactions.firstWhere((c) => c.id == replace.key);
      for (var add in c.input.entries) {
        var req = add.value;
        var count = replace.value * req;
        if (count % c.output > 0) {
          re[add.key] = (re[add.key] ?? 0) + 1;
          pool[c.id] = (pool[c.id] ?? 0) + count % c.output;
        }
        re[add.key] = (re[add.key] ?? 0) + (count ~/ c.output);
      }
      re.remove(replace.key);
    }
  }

  int two(List<String> input) {
    return 0;
  }
}

class Chem {
  final String id;
  int output;
  Map<String, int> input;

  Chem(this.id, this.output);

  factory Chem.from(String s) {
    var c = s.split(' ');
    return Chem(c.last, int.parse(c.first));
  }

  @override
  String toString() => '$input => $output $id';
}
