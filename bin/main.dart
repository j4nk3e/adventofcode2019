import 'dart:io';

// import 'package:adventofcode2019/a01.dart' as a01;
import 'package:adventofcode2019/a02.dart' as a02;

main(List<String> arguments) async {
  // final lines = await File('input/01/1').readAsLines();
  // print('1/1: ${a01.one(lines)}');
  // print('1/2: ${a01.two(lines)}');

  final codes =
      File('input/02/1').readAsStringSync().split(',').map(int.parse).toList();
  print('2/1: ${a02.one(codes)}');
  print('2/2: ${a02.two(codes)}');
}
