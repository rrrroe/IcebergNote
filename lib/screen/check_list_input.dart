// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebergnote/main.dart';
import 'package:icebergnote/notes.dart';
import 'package:icebergnote/postgresql/sync.dart';
import 'package:intl/intl.dart';
import 'package:yaml/yaml.dart';

final dateTimeFormat = DateFormat("yyyy-MM-dd HH:mm:ss'Z'");

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
    tmp += 'content: "${content.replaceAll('\n', '<br>')}"\n';
    tmp += 'finishState: $finishState\n';
    tmp +=
        'createTime: ${createTime == null ? '' : '${dateTimeFormat.format(createTime!)}Z'}\n';
    tmp +=
        'startTime: ${startTime == null ? '' : '${dateTimeFormat.format(startTime!)}Z'}\n';
    tmp +=
        'finishTime: ${finishTime == null ? '' : '${dateTimeFormat.format(finishTime!)}Z'}\n';
    tmp +=
        'alarmTime: ${alarmTime == null ? '' : '${dateTimeFormat.format(alarmTime!)}Z'}\n';
    tmp +=
        'giveUpTime: ${giveUpTime == null ? '' : '${dateTimeFormat.format(giveUpTime!)}Z'}\n';
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

  if (map['content'] != null)
    todo.content = map['content'].toString().replaceAll('<br>', '\n');

  if (map['finishState'].runtimeType == int)
    todo.finishState = map['finishState'];
  if (map['createTime'] != '' && map['createTime'] != null)
    todo.createTime = dateTimeFormat.parseUtc(map['createTime'].toString());
  if (map['startTime'] != '' && map['startTime'] != null)
    todo.startTime = dateTimeFormat.parseUtc(map['startTime'].toString());
  if (map['finishTime'] != '' && map['finishTime'] != null)
    todo.finishTime = dateTimeFormat.parseUtc(map['finishTime'].toString());
  if (map['alarmTime'] != '' && map['alarmTime'] != null)
    todo.alarmTime = dateTimeFormat.parseUtc(map['alarmTime'].toString());
  if (map['giveUpTime'] != '' && map['giveUpTime'] != null)
    todo.giveUpTime = dateTimeFormat.parseUtc(map['giveUpTime'].toString());

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
  List<int> todoCountResults = [0, 0, 0, 0];
  List<TextEditingController> todoListController = [];
  List<TextEditingController> todoListContentController = [];
  TextEditingController titleController = TextEditingController();
  bool isAll = false;
  Color fontColor = const Color.fromARGB(255, 48, 207, 121);
  Color backgroundColor = const Color.fromARGB(20, 48, 207, 121);

  List<int> todoCount() {
    List<int> todoCountResults = [0, 0, 0, 0];
    for (int i = 0; i < todoList.length; i++) {
      if (todoList[i].finishState == 1) {
        todoCountResults[1]++;
      } else if (todoList[i].finishState == 2) {
        todoCountResults[2]++;
      } else if (todoList[i].finishState == 3) {
        todoCountResults[3]++;
      } else if (todoList[i].finishState == 0) {
        todoCountResults[0]++;
      }
    }
    return todoCountResults;
  }

  @override
  void initState() {
    super.initState();
    todoList = stringToTodoList(widget.note.noteContext);
    for (int i = 0; i < todoList.length; i++) {
      if (todoList[i].finishState == 1) {
        todoCountResults[1]++;
      } else if (todoList[i].finishState == 2) {
        todoCountResults[2]++;
      } else if (todoList[i].finishState == 3) {
        todoCountResults[3]++;
      } else {
        todoCountResults[0]++;
      }
      todoListController.add(TextEditingController());
      todoListController[i].text = todoList[i].title;
      todoListContentController.add(TextEditingController());
      todoListContentController[i].text = todoList[i].content;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          actions: [
            IconButton(
                icon: isAll
                    ? const Icon(Icons.all_inbox)
                    : const Icon(Icons.inbox),
                onPressed: () {
                  isAll = !isAll;
                  setState(() {});
                }),
            const SizedBox(
              width: 10,
            )
          ],
        ),
        body: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          child: TextField(
                            textAlign: TextAlign.center,
                            controller: titleController,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                            minLines: 1,
                            maxLines: 2,
                            decoration: const InputDecoration(
                                labelText: "标题",
                                labelStyle: TextStyle(
                                  color: Colors.grey,
                                )),
                            onChanged: (value) async {
                              await realm.writeAsync(() {
                                widget.note.noteTitle = value;
                                widget.note.noteUpdateDate =
                                    DateTime.now().toUtc();
                              });
                            },
                          ),
                        ),
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
                                        (index) => Visibility(
                                          visible: isAll ||
                                              todoList[index].finishState ==
                                                  0 ||
                                              todoList[index].finishState == 2,
                                          child: Column(
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    alignment:
                                                        Alignment.topCenter,
                                                    width: 35,
                                                    height: Platform.isAndroid
                                                        ? 34
                                                        : 26,
                                                    child: Checkbox.adaptive(
                                                      fillColor:
                                                          MaterialStateProperty
                                                              .all(const Color
                                                                  .fromARGB(
                                                                  0, 0, 0, 0)),
                                                      checkColor: todoList[
                                                                      index]
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
                                                      onChanged: (bool? value) {
                                                        todoList[index]
                                                                .finishState =
                                                            todoList[index]
                                                                    .finishState +
                                                                1;
                                                        if (todoList[index]
                                                                .finishState >
                                                            1) {
                                                          todoList[index]
                                                              .finishState = 0;
                                                        }
                                                        switch (todoList[index]
                                                            .finishState) {
                                                          case 0:
                                                            todoList[index]
                                                                    .startTime =
                                                                null;
                                                            todoList[index]
                                                                    .finishTime =
                                                                null;
                                                            todoList[index]
                                                                    .giveUpTime =
                                                                null;
                                                            break;
                                                          case 1:
                                                            todoList[index]
                                                                    .finishTime =
                                                                DateTime.now()
                                                                    .toUtc();
                                                            todoList[index]
                                                                    .giveUpTime =
                                                                null;

                                                            break;
                                                          case 2:
                                                            todoList[index]
                                                                    .startTime =
                                                                DateTime.now()
                                                                    .toUtc();
                                                            todoList[index]
                                                                    .finishTime =
                                                                null;
                                                            todoList[index]
                                                                    .giveUpTime =
                                                                null;
                                                            break;
                                                          case 3:
                                                            todoList[index]
                                                                    .giveUpTime =
                                                                DateTime.now()
                                                                    .toUtc();
                                                            todoList[index]
                                                                    .startTime =
                                                                null;
                                                            todoList[index]
                                                                    .finishTime =
                                                                null;
                                                            break;
                                                        }
                                                        todoCountResults =
                                                            todoCount();
                                                        realm.write(() {
                                                          widget.note
                                                                  .noteContext =
                                                              todoListToString(
                                                                  todoList);
                                                          widget.note
                                                                  .noteUpdateDate =
                                                              DateTime.now()
                                                                  .toUtc();
                                                          if (todoCountResults[
                                                                      0] ==
                                                                  0 &&
                                                              todoCountResults[
                                                                      0] ==
                                                                  0) {
                                                            widget.note
                                                                    .noteFinishState =
                                                                '已完';
                                                          } else {
                                                            widget.note
                                                                    .noteFinishState =
                                                                '未完';
                                                          }
                                                        });
                                                        setState(() {});
                                                      },
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              0),
                                                      alignment:
                                                          Alignment.center,
                                                      child: TextField(
                                                        keyboardType:
                                                            TextInputType
                                                                .multiline,
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: checkTextStyle[
                                                            todoList[index]
                                                                .finishState],
                                                        controller:
                                                            todoListController[
                                                                index],
                                                        decoration:
                                                            InputDecoration(
                                                          border:
                                                              InputBorder.none,
                                                          isCollapsed: true,
                                                          contentPadding: Platform
                                                                  .isAndroid
                                                              ? const EdgeInsets
                                                                  .fromLTRB(
                                                                  5, 0, 0, 5)
                                                              : const EdgeInsets
                                                                  .all(0),
                                                        ),
                                                        minLines: 1,
                                                        maxLines: 3,
                                                        onChanged:
                                                            (value) async {
                                                          todoList[index]
                                                              .title = value;
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    child: Container(
                                                      height: 25,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              0),
                                                      alignment:
                                                          Alignment.bottomLeft,
                                                      child: Icon(
                                                        todoList[index]
                                                                .isCollapsed
                                                            ? Icons.arrow_right
                                                            : Icons
                                                                .arrow_drop_down,
                                                        size: 25,
                                                        color: fontColor,
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      todoList[index]
                                                              .isCollapsed =
                                                          !todoList[index]
                                                              .isCollapsed;

                                                      realm.write(() {
                                                        widget.note
                                                                .noteContext =
                                                            todoListToString(
                                                                todoList);
                                                        widget.note
                                                                .noteUpdateDate =
                                                            DateTime.now()
                                                                .toUtc();
                                                      });
                                                      setState(() {});
                                                    },
                                                  ),
                                                ],
                                              ),
                                              Visibility(
                                                visible: !todoList[index]
                                                    .isCollapsed,
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      margin: const EdgeInsets
                                                          .fromLTRB(
                                                          0, 10, 0, 0),
                                                      padding: const EdgeInsets
                                                          .fromLTRB(
                                                          0, 10, 0, 10),
                                                      color: Colors.white,
                                                      child: TextField(
                                                          textAlign:
                                                              TextAlign.start,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                Colors.black54,
                                                          ),
                                                          controller:
                                                              todoListContentController[
                                                                  index],
                                                          decoration:
                                                              InputDecoration(
                                                            border: InputBorder
                                                                .none,
                                                            isCollapsed: true,
                                                            contentPadding: Platform
                                                                    .isAndroid
                                                                ? const EdgeInsets
                                                                    .fromLTRB(
                                                                    5, 0, 0, 5)
                                                                : const EdgeInsets
                                                                    .all(0),
                                                          ),
                                                          maxLines: 10,
                                                          minLines: 1,
                                                          onChanged:
                                                              (value) async {
                                                            todoList[index]
                                                                    .content =
                                                                value;
                                                          }),
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Column(
                                                            children: [
                                                              Visibility(
                                                                visible: todoList[
                                                                            index]
                                                                        .createTime !=
                                                                    null,
                                                                child: Text(
                                                                  '创建时间：${todoList[index].createTime != null ? todoList[index].createTime!.toLocal().toString().substring(0, 19) : ''}',
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .black54),
                                                                ),
                                                              ),
                                                              Visibility(
                                                                visible: todoList[
                                                                            index]
                                                                        .startTime !=
                                                                    null,
                                                                child: Text(
                                                                  '开始时间：${todoList[index].startTime != null ? todoList[index].startTime!.toLocal().toString().substring(0, 19) : ''}',
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12),
                                                                ),
                                                              ),
                                                              Visibility(
                                                                visible: todoList[
                                                                            index]
                                                                        .finishTime !=
                                                                    null,
                                                                child: Text(
                                                                  '完成时间：${todoList[index].finishTime != null ? todoList[index].finishTime!.toLocal().toString().substring(0, 19) : ''}',
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12),
                                                                ),
                                                              ),
                                                              Visibility(
                                                                visible: todoList[
                                                                            index]
                                                                        .alarmTime !=
                                                                    null,
                                                                child: Text(
                                                                  '提醒时间：${todoList[index].alarmTime != null ? todoList[index].alarmTime!.toLocal().toString().substring(0, 19) : ''}',
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12),
                                                                ),
                                                              ),
                                                              Visibility(
                                                                visible: todoList[
                                                                            index]
                                                                        .giveUpTime !=
                                                                    null,
                                                                child: Text(
                                                                  '放弃时间：${todoList[index].giveUpTime != null ? todoList[index].giveUpTime!.toLocal().toString().substring(0, 19) : ''}',
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
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
                                                                color:
                                                                    fontColor,
                                                              ),
                                                            ),
                                                            onTap: () {
                                                              todoList.removeAt(
                                                                  index);
                                                              realm.write(() {
                                                                widget.note
                                                                        .noteContext =
                                                                    todoListToString(
                                                                        todoList);
                                                                widget.note
                                                                        .noteUpdateDate =
                                                                    DateTime.now()
                                                                        .toUtc();
                                                              });
                                                              todoListController
                                                                  .removeAt(
                                                                      index);
                                                              todoListContentController
                                                                  .removeAt(
                                                                      index);
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
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 250,
                          child: Column(
                            children: [
                              const SizedBox(height: 40),
                              Table(
                                children: [
                                  TableRow(children: [
                                    const Text('合计', textAlign: TextAlign.end),
                                    Text('    ${todoList.length}'),
                                  ]),
                                  TableRow(children: [
                                    const Text('未完成', textAlign: TextAlign.end),
                                    Text('    ${todoCountResults[0]}'),
                                  ]),
                                  TableRow(children: [
                                    const Text('已完成', textAlign: TextAlign.end),
                                    Text('    ${todoCountResults[1]}'),
                                  ]),
                                  TableRow(children: [
                                    const Text('进行中', textAlign: TextAlign.end),
                                    Text('    ${todoCountResults[2]}'),
                                  ]),
                                  TableRow(children: [
                                    const Text('已放弃', textAlign: TextAlign.end),
                                    Text('    ${todoCountResults[3]}'),
                                  ]),
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
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
                      onPressed: () async {
                        realm.write(() {
                          widget.note.noteContext = todoListToString(todoList);
                          widget.note.noteUpdateDate = DateTime.now().toUtc();
                        });
                        widget.onPageClosed();
                        syncNoteToRemote(widget.note);
                        Get.back();
                      },
                      child: const Text('保存'),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 50,
              right: 20,
              child: FloatingActionButton(
                onPressed: () {
                  todoList.add(Todo());
                  todoListController.add(TextEditingController());
                  todoListController.last.text = '';
                  todoListContentController.add(TextEditingController());
                  todoListContentController.last.text = '';
                  realm.write(() {
                    widget.note.noteContext = todoListToString(todoList);
                    widget.note.noteUpdateDate = DateTime.now().toUtc();
                  });
                  setState(() {});
                },
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
