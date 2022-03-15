import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../alarm.dart';
import '../sqflite.dart';

class AddEditAlarmPage extends StatefulWidget {
  final List<Alarm> alarmList;
  final int? index;

  //const AddEditAlarmPage({Key? key}) : super(key: key);
  const AddEditAlarmPage({required this.alarmList, this.index, Key? key})
      : super(key: key);

  @override
  _AddEditAlarmPageState createState() => _AddEditAlarmPageState();
}

class _AddEditAlarmPageState extends State<AddEditAlarmPage> {
  TextEditingController controller = TextEditingController();
  DateTime selectedDate = DateTime.now();

  void initEditAlarm() {
    if (widget.index != null) {
      selectedDate = widget.alarmList[widget.index!].alarmTime;
      controller.text = DateFormat('HH:mm').format(selectedDate);
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    initEditAlarm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 100,
        leading: GestureDetector(
          child: Container(
            alignment: Alignment.center,
            child: const Text(
              'キャンセル',
              style: TextStyle(color: Colors.orange),
            ),
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          GestureDetector(
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(right: 20),
              child: const Text(
                '保存',
                style: TextStyle(color: Colors.orange),
              ),
            ),
            onTap: () async {
              DateTime now = DateTime.now();
              DateTime? alarmTime;
              if (now.compareTo(selectedDate) == -1) {//now < selectedDate
                alarmTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedDate.hour,
                  selectedDate.minute,
                );
              } else {//now > selectedDate
                alarmTime = DateTime(
                  now.year,
                  now.month,
                  now.day + 1,
                  selectedDate.hour,
                  selectedDate.minute,
                );
              }
              Alarm alarm = Alarm(alarmTime: alarmTime);
              print('★１');
              if (widget.index != null) {
                print('★2');
                print(widget.index);
                alarm.id = widget.alarmList[widget.index!].id;
                print('★3');
                await DbProvider.updateData((alarm));
                print('★4');
              } else {
                print('★5');
                int id = await DbProvider.insertData(alarm);
                print('★6');
                alarm.id = id;
                print('★7');
                //      .add(alarm); // 「widget」を頭につけることで基となるWidgetで定義された変数を指定できる
              }
              Navigator.pop(context, alarm);
            },
          ),
        ],
        backgroundColor: Colors.black54,
        title: Container(
          padding: const EdgeInsets.only(left: 30),
          child: const Text(
            'アラームを追加',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        color: Colors.black,
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('時間', style: TextStyle(color: Colors.white)),
                  Container(
                    width: 70,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.orange),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: controller,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      readOnly: true,
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return CupertinoDatePicker(
                              initialDateTime: selectedDate,
                              mode: CupertinoDatePickerMode.time,
                              onDateTimeChanged: (newDate) {
                                String time =
                                    DateFormat('HH:mm').format(newDate);
                                selectedDate = newDate;
                                controller.text = time;
                                setState(() {});
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
