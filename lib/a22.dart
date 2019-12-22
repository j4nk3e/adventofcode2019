import 'dart:math';

import 'package:adventofcode2019/a.dart';

class A22 extends A {
  int one(List<String> input) {
    var count = 10007;
    var deck = Iterable<int>.generate(count).toList();
    for (var command in input) {
      List<int> shuffled;
      if (command.startsWith('deal with')) {
        var inc = int.parse(command.split(' ').last);
        shuffled = List<int>(deck.length);
        var n = 0;
        for (var i in deck) {
          shuffled[n] = i;
          n = (n + inc) % shuffled.length;
        }
      } else if (command.startsWith('deal into')) {
        shuffled = deck.reversed.toList();
      } else if (command.startsWith('cut')) {
        var offset = (int.parse(command.split(' ').last) + count) % count;
        shuffled = deck.skip(offset).toList();
        shuffled.addAll(deck.take(offset).toList());
      } else {
        throw Exception('unknown command');
      }
      deck = shuffled;
    }
    return deck.indexOf(2019);
  }

  int two(List<String> input) {
    var pos = BigInt.from(2020);
    var cards = BigInt.from(119315717514047);
    var count = BigInt.from(101741582076661);
    var o = BigInt.zero;
    var i = BigInt.one;
    var rev = (BigInt q) => q.modPow(cards - BigInt.two, cards);
    for (var command in input) {
      if (command.startsWith('deal with')) {
        var inc = BigInt.parse(command.split(' ').last);
        i *= rev(inc);
      } else if (command.startsWith('deal into')) {
        o -= i;
        i *= -BigInt.one;
      } else if (command.startsWith('cut')) {
        var offset = (BigInt.parse(command.split(' ').last) + cards);
        o += i * offset;
      } else {
        throw Exception('unknown command');
      }
    }
    o *= rev(BigInt.one - i);
    i = i.modPow(count, cards);
    return ((pos * i + (BigInt.one - i) * o) % cards).toInt();
  }
}
