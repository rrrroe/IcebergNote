// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebergnote/main.dart';
import 'package:icebergnote/notes.dart';
import 'package:intl/intl.dart';
import 'package:yaml/yaml.dart';

class Todo {
  String title = '';
  String content = '';
  int finishState = 0; //0：未完成，1：已完成，2：进行中，3：已放弃//
  DateTime? createTime = DateTime.now().toUtc();
  DateTime? startTime;
  DateTime? finishTime;
  DateTime? alarmTime;
  DateTime? giveUpTime;
  int priority = 0; //0：无，1：低，2：中，3：高//
  bool isCollapsed = true;
  String todoToString() {
    String tmp = '';
    tmp += 'title: "$title"\n';
    tmp += 'content: "$content"\n';
    tmp += 'finishState: $finishState\n';
    tmp += 'createTime: ${createTime ?? ''}\n';
    tmp += 'startTime: ${startTime ?? ''}\n';
    tmp += 'finishTime: ${finishTime ?? ''}\n';
    tmp += 'alarmTime: ${alarmTime ?? ''}\n';
    tmp += 'giveUpTime: ${giveUpTime ?? ''}\n';
    tmp += 'priority: $priority\n';
    tmp += 'isCollapsed: $isCollapsed';
    return tmp;
  }
}

Todo stringToTodo(String s) {
  Todo todo = Todo();
  if (s == '') return todo;

  var map = loadYaml(s);

  if (map['title'] != null) todo.title = map['title'].toString();

  if (map['content'] != null) todo.content = map['content'].toString();

  if (map['finishState'].runtimeType == int)
    todo.finishState = map['finishState'];
  if (map['createTime'] != '')
    todo.createTime = DateFormat("yyyy-MM-dd HH:mm:ss.SSSZ")
        .parseUtc(map['createTime'].toString());
  if (map['priority'].runtimeType == int) todo.priority = map['priority'];
  if (map['isCollapsed'].runtimeType == bool)
    todo.isCollapsed = map['isCollapsed'];
  return todo;
}

List<Todo> stringToTodoList(String s) {
  List<String> tmp = s.split('\n||||\n');
  List<Todo> todoList = [];
  if (tmp.isEmpty) {
    return [];
  } else {
    for (int i = 0; i < tmp.length; i++) {
      todoList.add(stringToTodo(tmp[i]));
    }
  }
  return todoList;
}

String todoListToString(List<Todo> todoList) {
  String s = '';
  for (int i = 0; i < todoList.length; i++) {
    s += todoList[i].todoToString();
    if (i < todoList.length - 1) s += '\n||||\n';
  }
  return s;
}

class CheckListEditPage extends StatefulWidget {
  const CheckListEditPage({
    super.key,
    required this.note,
    required this.onPageClosed,
  });
  final Notes note;
  final VoidCallback onPageClosed;
  @override
  State<CheckListEditPage> createState() => CheckListEditPageState();
}

class CheckListEditPageState extends State<CheckListEditPage> {
  List<Todo> todoList = [];
  List<TextEditingController> todoListController = [];
  List<TextEditingController> todoListContentController = [];
  Color fontColor = const Color.fromARGB(255, 48, 207, 121);
  Color backgroundColor = const Color.fromARGB(20, 48, 207, 121);

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    todoList = stringToTodoList(widget.note.noteContext);
    for (int i = 0; i < todoList.length; i++) {
      todoListController.add(TextEditingController());

      todoListController[i].text = todoList[i].title;
      todoListContentController.add(TextEditingController());
      todoListContentController[i].text = todoList[i].content;
    }
    List<TextStyle> checkTextStyle = [
      const TextStyle(
        fontSize: 20,
        color: Colors.black,
      ),
      TextStyle(
        fontSize: 20,
        color: fontColor,
        decoration: TextDecoration.lineThrough,
        decorationStyle: TextDecorationStyle.solid,
        decorationColor: fontColor,
      ),
      TextStyle(
        fontSize: 20,
        color: fontColor,
      ),
      const TextStyle(
        fontSize: 20,
        color: Colors.grey,
        decoration: TextDecoration.lineThrough,
        decorationStyle: TextDecorationStyle.solid,
        decorationColor: Colors.grey,
      ),
    ];
    return PopScope(
      onPopInvoked: (a) {},
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(""),
          actions: const [],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Container(
                  color: backgroundColor,
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(20),
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
                                    (index) => Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              alignment: Alignment.center,
                                              width: 35,
                                              child: Checkbox.adaptive(
                                                fillColor:
                                                    MaterialStateProperty.all(
                                                        const Color.fromARGB(
                                                            0, 0, 0, 0)),
                                                checkColor: todoList[index]
                                                            .finishState ==
                                                        3
                                                    ? Colors.grey
                                                    : fontColor,
                                                value: todoList[index]
                                                            .finishState ==
                                                        1
                                                    ? true
                                                    : todoList[index]
                                                                .finishState ==
                                                            0
                                                        ? false
                                                        : null,
                                                tristate: true,
                                                onChanged: (bool? value) async {
                                                  todoList[index].finishState++;
                                                  if (todoList[index]
                                                          .finishState >
                                                      3) {
                                                    todoList[index]
                                                        .finishState = 0;
                                                  }
                                                  realm.write(() {
                                                    widget.note.noteContext =
                                                        todoListToString(
                                                            todoList);
                                                  });
                                                  setState(() {});
                                                },
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(0),
                                                alignment: Alignment.topLeft,
                                                child: TextField(
                                                  keyboardType:
                                                      TextInputType.text,
                                                  textAlign: TextAlign.start,
                                                  style: checkTextStyle[
                                                      todoList[index]
                                                          .finishState],
                                                  controller:
                                                      todoListController[index],
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    isCollapsed: true,
                                                    contentPadding: Platform
                                                            .isAndroid
                                                        ? const EdgeInsets
                                                            .fromLTRB(
                                                            5, 0, 0, 5)
                                                        : const EdgeInsets.all(
                                                            0),
                                                  ),
                                                  maxLines: 5,
                                                  minLines: 1,
                                                  onChanged: (value) async {
                                                    todoList[index].title =
                                                        value;
                                                  },
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              child: Container(
                                                height: 25,
                                                padding:
                                                    const EdgeInsets.all(0),
                                                alignment: Alignment.bottomLeft,
                                                child: Icon(
                                                  todoList[index].isCollapsed
                                                      ? Icons.arrow_right
                                                      : Icons.arrow_drop_down,
                                                  size: 25,
                                                  color: fontColor,
                                                ),
                                              ),
                                              onTap: () {
                                                todoList[index].isCollapsed =
                                                    !todoList[index]
                                                        .isCollapsed;

                                                realm.write(() {
                                                  widget.note.noteContext =
                                                      todoListToString(
                                                          todoList);
                                                });
                                                setState(() {});
                                              },
                                            ),
                                          ],
                                        ),
                                        Visibility(
                                          visible: !todoList[index].isCollapsed,
                                          child: Column(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                color: Colors.white,
                                                child: TextField(
                                                    textAlign: TextAlign.start,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black54,
                                                    ),
                                                    controller:
                                                        todoListContentController[
                                                            index],
                                                    decoration: InputDecoration(
                                                      border: InputBorder.none,
                                                      isCollapsed: true,
                                                      contentPadding:
                                                          Platform.isAndroid
                                                              ? const EdgeInsets
                                                                  .fromLTRB(
                                                                  5, 0, 0, 5)
                                                              : const EdgeInsets
                                                                  .all(0),
                                                    ),
                                                    onChanged: (value) async {
                                                      todoList[index].content =
                                                          value;
                                                    }),
                                              ),
                                              const SizedBox(height: 5),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(00),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    GestureDetector(
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(0),
                                                        alignment: Alignment
                                                            .bottomLeft,
                                                        child: Icon(
                                                          Icons.delete,
                                                          size: 25,
                                                          color: fontColor,
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        todoList
                                                            .removeAt(index);
                                                        realm.write(() {
                                                          widget.note
                                                                  .noteContext =
                                                              todoListToString(
                                                                  todoList);
                                                        });
                                                        setState(() {});
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Divider(
                                          color: backgroundColor,
                                          thickness: 3,
                                        ),
                                      ],
                                    ),
                                  ) +
                                  List.generate(
                                    1,
                                    (index) => Column(
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Expanded(child: Container()),
                                            GestureDetector(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(0),
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
                                                todoListController.add(
                                                    TextEditingController());
                                                todoListController.last.text =
                                                    '';
                                                realm.write(() {
                                                  widget.note.noteContext =
                                                      todoListToString(
                                                          todoList);
                                                });
                                                setState(() {});
                                              },
                                            ),
                                            Expanded(child: Container()),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                    color: Theme.of(context).secondaryHeaderColor),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('格式'),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('复制'),
                    ),
                    TextButton(
                      onPressed: () {
                        realm.write(() {
                          widget.note.noteContext = todoListToString(todoList);
                        });
                        widget.onPageClosed();
                        Get.back();
                      },
                      child: const Text('保存'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
