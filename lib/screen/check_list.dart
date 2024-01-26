import 'dart:io';

import 'package:flutter/material.dart';
import 'package:icebergnote/notes.dart';

class Todo {
  String title = '';
  String content = '';
  int finishState = 0; //0：未完成，1：已完成，2：进行中，3：已放弃//
  DateTime? startTime;
  DateTime? finishTime;
  DateTime? alarmTime;
  DateTime? giveUpTime;
  int priority = 0; //0：无，1：低，2：中，3：高//
  String todoToString() {
    return '$title////$content////$finishState////$startTime////$finishTime////$alarmTime////$giveUpTime////$priority';
  }
}

Todo stringToTodo(String s) {
  List<String> tmp = s.split('////');
  Todo todo = Todo();
  if (tmp.isNotEmpty) todo.title = tmp[0];
  if (tmp.length > 1) todo.content = tmp[1];
  if (tmp.length > 2) todo.finishState = int.tryParse(tmp[2]) ?? 0;
  if (tmp.length > 3) todo.startTime = DateTime.tryParse(tmp[3]);
  if (tmp.length > 4) todo.finishTime = DateTime.tryParse(tmp[4]);
  if (tmp.length > 5) todo.alarmTime = DateTime.tryParse(tmp[5]);
  if (tmp.length > 6) todo.giveUpTime = DateTime.tryParse(tmp[6]);
  if (tmp.length > 7) todo.priority = int.tryParse(tmp[7]) ?? 0;
  return todo;
}

class CheckListEditWidget extends StatefulWidget {
  const CheckListEditWidget({super.key, required this.note});
  final Notes note;
  @override
  State<CheckListEditWidget> createState() => _CheckListEditWidgetState();
}

class _CheckListEditWidgetState extends State<CheckListEditWidget> {
  @override
  Widget build(BuildContext context) {
    List<String> todoStringList = widget.note.noteContext.split('||||');
    List<Todo> todoList = [];
    Color fontColor = const Color.fromARGB(20, 0, 140, 198);
    List<TextEditingController> todoListController = [];
    for (int i = 0; i < todoList.length; i++) {
      todoListController.add(TextEditingController());
      todoListController[i].text = todoList[i].title;
    }
    for (int i = 0; i < todoStringList.length; i++) {}
    return Card(
      elevation: 0,
      color: fontColor,
      child: Row(
        children: [
          Expanded(
            flex: 10,
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 30,
                ),
                alignment: Alignment.center,
                child: Column(
                  children: List.generate(
                        todoList.length,
                        (index) => Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              width: 35,
                              height: 35,
                              child: Checkbox.adaptive(
                                fillColor: MaterialStateProperty.all(
                                    const Color.fromARGB(0, 0, 0, 0)),
                                checkColor: fontColor,
                                value: false,
                                onChanged: (bool? value) async {
                                  todoList[index].finishState++;
                                  if (todoList[index].finishState >= 3) {
                                    todoList[index].finishState = 0;
                                  }
                                  setState(() {});
                                },
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(0),
                                alignment: Alignment.topLeft,
                                child: TextField(
                                  keyboardType: TextInputType.text,
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(fontSize: 26),
                                  controller: todoListController[index],
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    isCollapsed: true,
                                    contentPadding: Platform.isAndroid
                                        ? const EdgeInsets.fromLTRB(5, 0, 0, 5)
                                        : const EdgeInsets.all(0),
                                  ),
                                  maxLines: 5,
                                  minLines: 1,
                                  onChanged: (value) async {
                                    todoList[index].title = value;
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                            GestureDetector(
                              child: Container(
                                height: 25,
                                padding: const EdgeInsets.all(0),
                                alignment: Alignment.bottomLeft,
                                child: Icon(
                                  Icons.close,
                                  size: 25,
                                  color: fontColor,
                                ),
                              ),
                              onTap: () {
                                todoList.removeAt(index);
                                todoListController.removeAt(index);
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      ) +
                      List.generate(
                          1,
                          (index) => Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(child: Container()),
                                  GestureDetector(
                                    child: Container(
                                      padding: const EdgeInsets.all(0),
                                      alignment: Alignment.center,
                                      height: 25,
                                      child: Icon(
                                        Icons.add,
                                        size: 25,
                                        color: fontColor,
                                      ),
                                    ),
                                    onTap: () {
                                      todoList.add(Todo());
                                      todoListController
                                          .add(TextEditingController());
                                      todoListController.last.text = '';
                                      setState(() {});
                                    },
                                  ),
                                  Expanded(child: Container()),
                                ],
                              )),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
