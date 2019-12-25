import 'dart:async';
import 'dart:isolate';

import 'package:adventofcode2019/a.dart';
import 'package:adventofcode2019/intcode.dart';

class Message {
  final List<String> code;
  final SendPort sendPort;
  final SendPort backChannel;
  final int port;

  Message(this.code, this.sendPort, this.backChannel, this.port);
}

void runIntCode(Message message) async {
  var buf = <int>[message.port];
  var receivePort = ReceivePort();
  message.backChannel.send(MapEntry(message.port, receivePort.sendPort));
  var intCode = IntCode.from(message.code, inputFunction: () {
    if (buf.isEmpty) {
      return -1;
    }
    return buf.removeAt(0);
  });
  receivePort.listen((d) {
    if (d.port == message.port) {
      buf.addAll([d.x, d.y]);
    }
  });
  while (true) {
    var port = await Future.delayed(Duration.zero, intCode.microtask);
    if (port == null) {
      continue;
    }
    var x = intCode.run(message.port);
    var y = intCode.run(message.port);
    message.sendPort.send(Packet(port, x, y));
  }
}

class Packet {
  final int port;
  final int x;
  final int y;

  Packet(this.port, this.x, this.y);

  @override
  String toString() => 'Packet($x, $y) => $port';
}

class A23 extends AA {
  Future<int> one(List<String> input) async {
    var runners = <Future>[];
    var network = <int, SendPort>{};
    var backChannel = ReceivePort();
    var receivePort = ReceivePort();
    for (var i in Iterable.generate(50)) {
      var message =
          Message(input, receivePort.sendPort, backChannel.sendPort, i);
      runners.add(Isolate.spawn(runIntCode, message));
    }
    print('${runners.length} runners started');
    await backChannel
        .take(runners.length)
        .listen((d) => network[d.key] = d.value)
        .asFuture();
    print('All ports initialized');
    var nat = StreamController<Packet>();
    var l = receivePort.listen((d) {
      if (d.waiting) {
        return;
      } else if (d.port == 255) {
        nat.add(d);
      } else {
        print(d);
        network[d.port].send(d);
      }
    });
    var y = (await nat.stream.first).y;
    await l.cancel();
    return y;
  }

  Future<int> two(List<String> input) async {
    var runners = <Future>[];
    var network = <int, SendPort>{};
    var backChannel = ReceivePort();
    var receivePort = ReceivePort();
    for (var i in Iterable.generate(50)) {
      var message =
          Message(input, receivePort.sendPort, backChannel.sendPort, i);
      runners.add(Isolate.spawn(runIntCode, message));
    }
    print('${runners.length} runners started');
    await backChannel
        .take(runners.length)
        .listen((d) => network[d.key] = d.value)
        .asFuture();
    print('All ports initialized');
    var nat = StreamController<Packet>();
    var sentLast;
    var sendNext;
    var timeout = () {
      if (sentLast != null && sendNext != null && sentLast.y == sendNext.y) {
        nat.add(sendNext);
      } else if (sendNext != null) {
        print('RESET $sendNext');
        sentLast = sendNext;
        sendNext = null;
        network[0].send(sentLast);
      }
    };
    var natTimeout = Duration(milliseconds: 100);
    var t = Timer(natTimeout, timeout);
    var l = receivePort.listen((d) async {
      t.cancel();
      if (d.port == 255) {
        print('NAT $d');
        sendNext = Packet(0, d.x, d.y);
      } else {
        network[d.port].send(d);
      }
      t = Timer(natTimeout, timeout);
    });
    var p = await nat.stream.first;
    await l.cancel();
    return p.y;
  }
}
