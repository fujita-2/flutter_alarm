import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'alarm.dart';

class DbProvider {
  static Database? database;
  static const String tableName = 'alarm';

  static Future<void> _createTable(Database db, int version) async {
    await db.execute(
        'CREATE TABLE $tableName(id INTEGER PRIMARY KEY AUTOINCREMENT, alarm_time TEXT, is_active INTEGER)');
  }

  static Future<Database> initDb() async {
    String path = join(await getDatabasesPath(), 'alarm_app.db');
    return await openDatabase(path, version: 1, onCreate: _createTable);
  }

  static Future<Database?> setDb() async {
    database ??= await initDb();
    return database;
  }

  static Future<List<Alarm>> getData() async {
    final List<Map<String, dynamic>> maps = await database!.query(tableName);
    print('★getData★');
    print(maps);
    if (maps.isEmpty) {
      return [];
    } else {
      List<Alarm> alarmList = List.generate(
        maps.length,
        ((index) => Alarm(
              id: maps[index]['id'],
              alarmTime: DateTime.parse(maps[index]['alarm_time']),
              isActive: maps[index]['is_active'] == 1,
            )),
      );
      return alarmList;
    }
  }

  static Future<int> insertData(Alarm alarm) async {
    await database!.insert(tableName, {
      'alarm_time': alarm.alarmTime.toString(),
      'is_active': alarm.isActive ? 1 : 0
    });
    final List<Map<String, dynamic>> maps = await database!.query(tableName);
    return maps.last['id'];
  }

  static Future<void> updateData(Alarm alarm) async {
    await database!.update(
      tableName,
      {
        'alarm_time': alarm.alarmTime.toString(),
        'is_active': alarm.isActive ? 1 : 0
      },
      where: 'id = ?',
      whereArgs: [alarm.id],
    );
  }

  static Future<void> deleteData(int id) async {
    await database!.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
