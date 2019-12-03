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

import "package:test/test.dart";

main(List<String> arguments) async {
  final day = arguments.isEmpty ? '01' : arguments.first;
  final input = arguments.length < 2 ? '1' : arguments[1];
  final file = File('input/$day/$input');
  final lines = await file.exists()
      ? await file.readAsLines()
      : await File('input/$day/1').readAsLines();

  final days = <String, A>{
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
  };
  final func = input == '1' ? days[day].one : days[day].two;

  final watch = Stopwatch();
  watch.start();
  print('result: ${func(lines)}');
  print('ran ${watch.elapsedMilliseconds}ms');
}
