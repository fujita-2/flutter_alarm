import 'dart:async';

//import 'dart:html';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alarm/pages/add_edit_alarm_page.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

//import 'package:timezone/standalone.dart';
import '../alarm.dart';
import '../sqflite.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Alarm> alarmList = [];

  /*
  Timer? _timer;
  */
  DateTime time = DateTime.now();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initDb() async {
    await DbProvider.setDb();
    alarmList = await DbProvider.getData();
    alarmList.sort((a, b) => a.alarmTime.compareTo(b.alarmTime));
    setState(() {});
  }

  Future<void> rebuild() async {
    alarmList = await DbProvider.getData();
    alarmList.sort((a, b) => a.alarmTime.compareTo(b.alarmTime));
    setState(() {});
  }

  void initiaLizeNotification() {
    flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('ic_launcher'),
        iOS: IOSInitializationSettings(),
      ),
    );
  }

  void setNotification(int id, DateTime alarmTime) {
    flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'アラーム',
      '時間になりました',
      //★tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),,
      tz.TZDateTime.from(alarmTime, tz.local),
      const NotificationDetails(
          android: AndroidNotificationDetails(
            'id',
            'name',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: IOSNotificationDetails()),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation
              .absoluteTime /*iosでサマータイム考慮しない*/,
      androidAllowWhileIdle: true /*androidで省電力でも通知する)*/,
    );
  }

  void notification() {
    flutterLocalNotificationsPlugin.show(
      1,
      'アラーム',
      '時間になりました',
      const NotificationDetails(
          android: AndroidNotificationDetails(
            'id',
            'name',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: IOSNotificationDetails()),
    );
  }

  @override
  void initState() {
    super.initState();
    initDb();
    initiaLizeNotification();
    /*
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        time = time.add(const Duration(seconds: 1));
        for (var alarm in alarmList) {
          if (alarm.isActive &&
              alarm.alarmTime.hour == time.hour &&
              alarm.alarmTime.minute == time.minute &&
              time.second == 0) {
            notification();
          }
        }
      },
    );
    */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            backgroundColor: Colors.black,
            largeTitle: const Text(
              'アラーム',
              style: TextStyle(color: Colors.white),
            ),
            trailing: GestureDetector(
              child: const Icon(
                Icons.add,
                color: Colors.orange,
              ),
              onTap: () async {
                var result = await Navigator.push(
                    // 遷移先ページで更新されたalarmListに対してsetStateしたいのでawaitする
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AddEditAlarmPage(alarmList: alarmList)));
                if (result != null) {
                  // result には　Navigator.popの第2引数が入っている
                  setNotification(result.id, result.alarmTime);
                  rebuild();
                }
              },
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                Alarm alarm = alarmList[index];
                return Column(
                  children: [
                    if (index == 0)
                      const Divider(
                        color: Colors.grey,
                        height: 1,
                      ),
                    Slidable(
                      // TODO:Key
                      key: ValueKey(alarm.id),
                      endActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        dismissible: DismissiblePane(
                          onDismissed: () async {
                            await DbProvider.deleteData(alarm.id);
                            rebuild();
                          },
                        ),
                        children: [
                          SlidableAction(
                            onPressed: (context) async {
                              await DbProvider.deleteData(alarm.id);
                              rebuild();
                            },
                            backgroundColor: Colors.red,
                            icon: Icons.delete,
                            label: '削除',
                          )
                        ],
                      ),
                      child: ListTile(
                        title: Text(
                          DateFormat('HH:mm').format(alarm.alarmTime),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                          ),
                        ),
                        trailing: CupertinoSwitch(
                          value: alarm.isActive,
                          onChanged: (newValue) async {
                            alarm.isActive = newValue;
                            await DbProvider.updateData(alarm);
                            rebuild();
                          },
                        ),
                        onTap: () async {
                          await Navigator.push(
                              // 遷移先ページで更新されたalarmListに対してsetStateしたいのでawaitする
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddEditAlarmPage(
                                      alarmList: alarmList, index: index)));
                          setNotification(index, alarmList[index].alarmTime);
                          rebuild();
                        },
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                      height: 0,
                    ),
                  ],
                );
              },
              childCount: alarmList.length,
            ),
          ),
        ],
      ),
    );
  }
}
