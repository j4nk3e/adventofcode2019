import 'dart:io';

import 'package:adventofcode2019/a.dart';
import 'package:adventofcode2019/a01.dart';
import 'package:adventofcode2019/a02.dart';
import 'package:adventofcode2019/a03.dart';
import 'package:adventofcode2019/a04.dart';
import 'package:adventofcode2019/a05.dart';
import 'package:adventofcode2019/a06.dart';
import 'package:adventofcode2019/a07.dart';
import 'package:adventofcode2019/a08.dart';
import 'package:adventofcode2019/a09.dart';
import 'package:adventofcode2019/a10.dart';
import 'package:adventofcode2019/a11.dart';
import 'package:adventofcode2019/a12.dart';
import 'package:adventofcode2019/a13.dart';
import 'package:adventofcode2019/a14.dart';
import 'package:adventofcode2019/a15.dart';
import 'package:adventofcode2019/a16.dart';
import 'package:adventofcode2019/a17.dart';
import 'package:adventofcode2019/a18.dart';
import 'package:adventofcode2019/a19.dart';
import 'package:adventofcode2019/a20.dart';
import 'package:adventofcode2019/a21.dart';
import 'package:adventofcode2019/a22.dart';
import 'package:adventofcode2019/a23.dart';
import 'package:adventofcode2019/a24.dart';
import 'package:adventofcode2019/a25.dart';
import 'package:sprintf/sprintf.dart';

main(List<String> arguments) async {
  if (arguments.isEmpty) {
    return benchmark();
  }
  final day = arguments.first;
  final input = arguments.length < 2 ? '1' : arguments[1];
  final file = File('input/$day/$input');
  final lines = await file.exists()
      ? await file.readAsLines()
      : await File('input/$day/1').readAsLines();

  final days = <String, dynamic>{
    '01': A01(),
    '02': A02(),
    '03': A03(),
    '04': A04(),
    '05': A05(),
    '06': A06(),
    '07': A07(),
    '08': A08(),
    '09': A09(),
    '10': A10(),
    '11': A11(),
    '12': A12(),
    '13': A13(),
    '14': A14(),
    '15': A15(),
    '16': A16(),
    '17': A17(),
    '18': A18(),
    '19': A19(),
    '20': A20(),
    '21': A21(),
    '22': A22(),
    '23': A23(),
    '24': A24(),
    '25': A25(),
  };
  final func = input == '1' ? days[day].one : days[day].two;

  final watch = Stopwatch();
  watch.start();
  print('result: ${await func(lines)}');
  print('ran ${watch.elapsedMilliseconds}ms');
}

void benchmark() async {
  var inputs = <List<String>>[];
  for (var day in Iterable.generate(24)) {
    final file = File(sprintf('input/%02i/1', [day + 1]));
    final lines = await file.exists() ? await file.readAsLines() : [''];
    inputs.add(lines);
  }

  final watch = Stopwatch();
  watch.start();
  final days = [
    A01(),
    A02(),
    A03(),
    A04(),
    A05(),
    A06(),
    A07(),
    A08(),
    A09(),
    A10(),
    A11(),
    A12(),
    A13(),
    A14(),
    A15(),
    A16(),
    A17(),
    A18(),
    A19(),
    A20(),
    A21(),
    A22(),
    A23(),
    A24(),
    A25(),
  ];
  for (var day in Iterable.generate(24)) {
    var d = days[day];
    if (d is AA) {
      await d.one(inputs[day]);
      await d.two(inputs[day]);
    } else if (d is A) {
      d.one(inputs[day]);
      d.two(inputs[day]);
    }
  }
  print('ran ${watch.elapsedMilliseconds}ms for all files');
}
