import 'dart:async';
import 'dart:io';

import 'package:adventofcode2019/a.dart';
import 'package:adventofcode2019/intcode.dart';
import 'package:console/console.dart';

class A25 extends AA {
  List<String> inventory = [];
  List<Room> map = [];
  Set<String> blacklist = Set.from(['infinite loop']);
  var room = Room();
  IntCode savePoint;
  IntCode intCode;
//  items needed: spool of cat6, fixed point, shell, candy cane
  final directions = {'north': '↑', 'south': '↓', 'east': '→', 'west': '←'};
  void printMap() {
    var s = map.map((r) => '${r.name}(${r.items.join(", ")})').join(', ');
    print(s);
  }

  Future<int> one(List<String> prog) async {
    Console.init();
    intCode = IntCode.from(prog);
    var lastDirection;
    var lastItem;
    var input;
    var command = '';
    while (true) {
      while (true) {
        String out = intCode.runUntilIO(input);
        input = null;
        if (out.startsWith('== ')) {
          Console.setTextColor(Color.WHITE.id);
          var pos = out.substring(3, out.length - 4);
          var r = map.firstWhere((r) => r.name == pos, orElse: () => null);
          if (r != null) {
            room = r;
          } else {
            var newRoom = Room()..name = pos;
            room.exit[lastDirection] = r;
            map.add(room);
            room = newRoom;
          }
          print(room.name);
        } else if (out.startsWith('Items in your inventory:')) {
          Console.setTextColor(Color.LIGHT_CYAN.id);
          inventory.clear();
          String i;
          do {
            i = intCode.runUntilIO();
            if (i.startsWith('- ')) {
              var item = i.substring(2).trim();
              inventory.add(item);
            }
          } while (i.startsWith('- '));
          print(inventory
              .asMap()
              .entries
              .map((e) => '${e.key}: ${e.value}')
              .join('\n'));
        } else if (out.startsWith('Doors here lead:')) {
          Console.setTextColor(Color.LIME.id);
          String i;
          do {
            i = intCode.runUntilIO();
            if (i.startsWith('- ')) {
              var dir = i.substring(2).trim();
              var e = room.exit[dir];
              if (e == null) {
                room.exit[dir] = null;
              }
            }
          } while (i.startsWith('- '));
          print(room.exit.keys.map((a) => directions[a]).join(', '));
        } else if (out.startsWith('Items here:')) {
          Console.setTextColor(Color.MAGENTA.id);
          room.items.clear();
          String i;
          do {
            i = intCode.runUntilIO();
            if (i.startsWith('- ')) {
              room.items.add(i.substring(2).trim());
            }
          } while (i.startsWith('- '));
          print(room.items.join(', '));
        } else if (out.trim().isNotEmpty) {
          Console.setTextColor(Color.CYAN.id);
          print(out.trim());
        }
        if (intCode.instruction is Input) {
          break;
        } else if (intCode.instruction == null) {
          Console.setTextColor(Color.RED.id);
          print('> Program ended, blacklisting $lastItem');
          blacklist.add(lastItem);
          break;
        }
      }
      Console.setTextColor(Color.GOLD.id);
      while (input == null) {
        if (command.startsWith('d ')) {
          command = 'i';
        } else if (command == 's') {
          command = 'i';
        } else {
          command = await readInput('${room.name} > ');
        }
        if (command.startsWith('t ')) {
          var id = int.tryParse(command.substring(2)) ?? 0;
          if (room.items.length > id) {
            var item = room.items[id];
            if (blacklist.contains(item)) {
              print('Ignoring blacklisted item $item');
            } else {
              input = 'take $item';
              inventory.add(item);
              lastItem = item;
            }
          } else {
            print('>> room is empty');
          }
        } else if (command.startsWith('d ')) {
          var id = int.tryParse(command.substring(2)) ?? 0;
          if (inventory.length > id) {
            input = 'drop ${inventory[id]}';
          } else {
            print('>> no such item');
          }
        } else if (command == 'i') {
          input = 'inv';
        } else if (command == 'q') {
          return 0;
        } else if (command == 'save') {
          await save();
        } else if (command == 'load') {
          await load();
        } else if (command == 'map') {
          printMap();
        } else if (command == 'w') {
          input = 'north';
          lastDirection = input;
        } else if (command == 'a') {
          input = 'west';
          lastDirection = input;
        } else if (command == 's') {
          input = 'south';
          lastDirection = input;
        } else if (command == 'd') {
          input = 'east';
          lastDirection = input;
        } else {
          input = '$command';
        }
      }
    }
  }

  void save() async {
    var f = File('dump');
    await f.writeAsString(intCode.toJson());
  }

  void load() async {
    var f = File('dump');
    if (await f.exists()) {
      intCode = IntCode.load(await f.readAsString());
    }
  }

  Future<int> two(List<String> input) async {
    return 0;
  }
}

class Room {
  String name;
  List<String> items = [];
  Map<String, Room> exit = {};

  Room();

  bool operator ==(dynamic o) => o is Room && o.name == name;
}
