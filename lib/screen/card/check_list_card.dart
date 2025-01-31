import 'package:flutter/material.dart';
import 'package:icebergnote/main.dart';
import 'package:icebergnote/class/notes.dart';
import 'package:icebergnote/postgresql/sync.dart';
import 'package:icebergnote/screen/input/check_list_input.dart';
import 'package:icebergnote/screen/search_screen.dart';
import 'package:icebergnote/theme.dart';
import 'dart:ui' as ui;
import '../noteslist_screen.dart';

Future<Todo> setTodoStatus(
  BuildContext context,
  TapUpDetails? tapUpdetails,
  LongPressStartDetails? longPressStartDetails,
  Todo todo,
) async {
  // 使用 await 等待 showMenu 完成
  final value = await showMenu<int>(
    context: context,
    shadowColor: Colors.grey,
    elevation: 20,
    shape: RoundedRectangleBorder(
      side: BorderSide(
        color: Colors.grey.shade300,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    position: tapUpdetails != null
        ? RelativeRect.fromLTRB(
            tapUpdetails.globalPosition.dx,
            tapUpdetails.globalPosition.dy,
            tapUpdetails.globalPosition.dx,
            tapUpdetails.globalPosition.dy,
          )
        : RelativeRect.fromLTRB(
            longPressStartDetails!.globalPosition.dx,
            longPressStartDetails.globalPosition.dy,
            longPressStartDetails.globalPosition.dx,
            longPressStartDetails.globalPosition.dy,
          ),
    items: [
      PopupMenuItem<int>(
        value: 0, // 未完成
        child: Container(
          decoration: BoxDecoration(
            color: todoColor.todoBackground,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Text(
            '未完成',
            style: TextStyle(
              color: todoColor.todoFont,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      PopupMenuItem<int>(
        value: 2, // 进行中
        child: Container(
          decoration: BoxDecoration(
            color: todoColor.inprogressground,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Text(
            '进行中',
            style: TextStyle(
              color: todoColor.inprogressFont,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      PopupMenuItem<int>(
        value: 1, // 已完成
        child: Container(
          decoration: BoxDecoration(
            color: todoColor.doneBackground,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Text(
            '已完成',
            style: TextStyle(
              color: todoColor.doneFont,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      PopupMenuItem<int>(
        value: 3, // 已放弃
        child: Container(
          decoration: BoxDecoration(
            color: todoColor.giveupBackground,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Text(
            '已放弃',
            style: TextStyle(
              color: todoColor.giveupFont,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    ],
  );

  // 如果选择了一个有效的值，更新 finishState
  if (value != null) {
    todo.finishState = value;
    switch (value) {
      case 2:
        todo.finishTime = null;
        todo.giveUpTime = null;
        break;
      case 3:
        todo.giveUpTime = DateTime.now().toUtc();
        todo.finishTime = null;
        break;
    }
  }

  // 异步函数的返回值，直接返回 todo
  return todo;
}

class CheckListCard extends StatefulWidget {
  const CheckListCard(
      {super.key,
      required this.note,
      required this.mod,
      required this.context,
      required this.refreshList,
      required this.searchText});

  final Notes note;
  final int mod;
  final BuildContext context;
  final VoidCallback refreshList;
  final String searchText;
  @override
  State<CheckListCard> createState() => CheckListCardState();
}

class CheckListCardState extends State<CheckListCard> {
  @override
  Widget build(BuildContext context) {
    List<Todo> todoList = stringToTodoList(widget.note.noteContext);
    List<int> todoCountResults = [0, 0, 0, 0];
    Color fontColor = const Color.fromARGB(255, 48, 207, 121);
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
    }
    return GestureDetector(
      child: Card(
        margin: const EdgeInsets.fromLTRB(15, 0, 15, 10),
        elevation: 0,
        shadowColor: Colors.grey,
        color: const Color.fromARGB(20, 0, 140, 198),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 30,
                    alignment: Alignment.center,
                    child: Checkbox.adaptive(
                      fillColor: WidgetStateProperty.all(
                          const Color.fromARGB(0, 0, 0, 0)),
                      checkColor: widget.note.noteFinishState == '已完'
                          ? Colors.grey
                          : fontColor,
                      value: widget.note.noteFinishState == '已完' ? true : false,
                      tristate: false,
                      onChanged: (bool? value) {
                        if (value == true) {
                          if (todoCountResults[0] + todoCountResults[2] != 0) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('确认操作'),
                                  content: const Text('还有事项未完成，确定要强制清单完成吗？'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('取消'),
                                      onPressed: () {
                                        Navigator.of(context).pop(); // 关闭弹窗
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('确定'),
                                      onPressed: () {
                                        Navigator.of(context).pop(); // 关闭弹窗
                                        realm.write(() {
                                          widget.note.noteFinishState =
                                              value! ? '已完' : '未完';
                                          widget.note.noteUpdateDate =
                                              DateTime.now().toUtc();
                                          widget.note.noteFinishDate =
                                              DateTime.now().toUtc();
                                        });
                                        setState(() {});
                                        syncNoteToRemote(widget.note);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            realm.write(() {
                              widget.note.noteFinishState =
                                  value! ? '已完' : '未完';
                              widget.note.noteUpdateDate =
                                  DateTime.now().toUtc();
                              widget.note.noteFinishDate =
                                  DateTime.now().toUtc();
                            });
                            setState(() {});
                            syncNoteToRemote(widget.note);
                          }
                        } else if (value == false) {
                          if (todoCountResults[0] + todoCountResults[2] == 0) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('确认操作'),
                                  content: const Text('事项已全部完成，确定要强制清单未完成吗？'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('取消'),
                                      onPressed: () {
                                        Navigator.of(context).pop(); // 关闭弹窗
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('确定'),
                                      onPressed: () {
                                        Navigator.of(context).pop(); // 关闭弹窗
                                        realm.write(() {
                                          widget.note.noteFinishState =
                                              value! ? '已完' : '未完';
                                          widget.note.noteUpdateDate =
                                              DateTime.now().toUtc();
                                          widget.note.noteFinishDate =
                                              DateTime.now().toUtc();
                                        });
                                        setState(() {});
                                        syncNoteToRemote(widget.note);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            realm.write(() {
                              widget.note.noteFinishState =
                                  value! ? '已完' : '未完';
                              widget.note.noteUpdateDate =
                                  DateTime.now().toUtc();
                              widget.note.noteFinishDate =
                                  DateTime.now().toUtc();
                            });
                            setState(() {});
                            syncNoteToRemote(widget.note);
                          }
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    child: widget.note.noteTitle.contains(widget.searchText) &&
                            widget.searchText != ''
                        ? buildRichText(
                            widget.note.noteTitle,
                            widget.searchText,
                            const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color.fromARGB(255, 0, 140, 198),
                                fontFamily: 'LXGWWenKai'),
                            TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color:
                                    const ui.Color.fromARGB(255, 0, 140, 198),
                                backgroundColor: Colors.yellow[100],
                                fontFamily: 'LXGWWenKai'),
                          )
                        : Text(
                            widget.note.noteTitle,
                            maxLines: 5,
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color.fromARGB(255, 0, 140, 198),
                                fontFamily: 'LXGWWenKai'),
                          ),
                  ),
                ],
              ),
              Row(
                children: [
                  Visibility(
                      visible: todoCountResults[0] > 0,
                      child: Text('未完成 ${todoCountResults[0]}   ')),
                  Visibility(
                      visible: todoCountResults[1] > 0,
                      child: Text('已完成 ${todoCountResults[1]}   ')),
                  Visibility(
                      visible: todoCountResults[2] > 0,
                      child: Text('进行中 ${todoCountResults[2]}   ')),
                  Visibility(
                      visible: todoCountResults[3] > 0,
                      child: Text('已放弃 ${todoCountResults[3]}   ')),
                ],
              ),
              Visibility(
                visible: widget.note.noteTitle != "",
                child: const SizedBox(
                  height: 5,
                ),
              ),
              Visibility(
                visible: widget.note.noteContext != "",
                child: widget.note.noteContext.contains(widget.searchText) &&
                        widget.searchText != ''
                    ? buildRichText(
                        widget.note.noteContext
                            .replaceAll(RegExp('\n|/n'), '  '),
                        widget.searchText,
                        const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontFamily: 'LXGWWenKai'),
                        TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            backgroundColor: Colors.yellow[100],
                            fontFamily: 'LXGWWenKai'),
                      )
                    : Column(
                        children: List.generate(
                          todoList.length,
                          (index) => Visibility(
                            visible: todoList[index].finishState == 0 ||
                                todoList[index].finishState == 2,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  height: 30,
                                  alignment: Alignment.center,
                                  child: GestureDetector(
                                    onSecondaryTapUp: (details) async {
                                      // 监听右键点击并弹出菜单
                                      Todo newTodo = await setTodoStatus(
                                          context,
                                          details,
                                          null,
                                          todoList[index]);
                                      todoList[index] = newTodo;
                                      setState(() {});
                                      realm.write(() {
                                        widget.note.noteContext =
                                            todoListToString(todoList);
                                        widget.note.noteUpdateDate =
                                            DateTime.now().toUtc();
                                      });
                                      syncNoteToRemote(widget.note);
                                    },
                                    onLongPressStart: (details) async {
                                      // 监听长按点击并弹出菜单
                                      Todo newTodo = await setTodoStatus(
                                          context,
                                          null,
                                          details,
                                          todoList[index]);
                                      todoList[index] = newTodo;
                                      setState(() {});
                                      realm.write(() {
                                        widget.note.noteContext =
                                            todoListToString(todoList);
                                        widget.note.noteUpdateDate =
                                            DateTime.now().toUtc();
                                      });
                                      syncNoteToRemote(widget.note);
                                    },
                                    child: Checkbox.adaptive(
                                      fillColor: WidgetStateProperty.all(
                                          const Color.fromARGB(0, 0, 0, 0)),
                                      checkColor:
                                          todoList[index].finishState == 3
                                              ? Colors.grey
                                              : fontColor,
                                      value: todoList[index].finishState == 1
                                          ? true
                                          : todoList[index].finishState == 0
                                              ? false
                                              : null,
                                      tristate: true,
                                      onChanged: (bool? value) {
                                        if (todoList[index].finishState == 0 ||
                                            todoList[index].finishState == 2) {
                                          todoList[index].finishState = 1;
                                        } else {
                                          todoList[index].finishState = 0;
                                        }
                                        switch (todoList[index].finishState) {
                                          case 0:
                                            todoList[index].startTime = null;
                                            todoList[index].finishTime = null;
                                            todoList[index].giveUpTime = null;
                                            break;
                                          case 1:
                                            todoList[index].finishTime =
                                                DateTime.now().toUtc();
                                            todoList[index].giveUpTime = null;
                                            break;
                                        }
                                        realm.write(() {
                                          widget.note.noteContext =
                                              todoListToString(todoList);
                                          widget.note.noteUpdateDate =
                                              DateTime.now().toUtc();
                                        });
                                        setState(() {});
                                        syncNoteToRemote(widget.note);
                                      },
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    todoList[index].title,
                                    textAlign: TextAlign.left,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                    style: checkTextStyle[
                                        todoList[index].finishState],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
              Visibility(
                visible: widget.note.noteType +
                        widget.note.noteProject +
                        widget.note.noteFolder !=
                    "",
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      padding: const EdgeInsets.all(0),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.note.noteType,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color.fromARGB(255, 56, 128, 186),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(0),
                      alignment: Alignment.centerLeft,
                      width: 79,
                      child: Text(
                        widget.note.noteProject,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color.fromARGB(255, 215, 55, 55),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(0),
                      alignment: Alignment.centerLeft,
                      width: 150,
                      child: Text(
                        widget.note.noteFolder,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color.fromARGB(255, 4, 123, 60),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CheckListEditPage(
              onPageClosed: () {
                widget.refreshList();
              },
              note: widget.note,
            ),
          ),
        );
      },
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            if (widget.mod == 2) {
              return BottomPopSheetDeleted(
                note: widget.note,
                onDialogClosed: () {
                  widget.refreshList();
                },
              );
            } else {
              return BottomPopSheet(
                note: widget.note,
                onDialogClosed: () {
                  widget.refreshList();
                },
              );
            }
          },
        );
      },
    );
  }
}
