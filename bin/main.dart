import 'dart:io';

import 'package:adventofcode2019/a01.dart' as a01;

main(List<String> arguments) async {
  final lines = await File('input/01/1').readAsLines();

  print('1/1: ${a01.one(lines)}');
  print('1/2: ${a01.two(lines)}');
}
