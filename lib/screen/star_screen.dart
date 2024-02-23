import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icebergnote/card.dart';
import 'package:icebergnote/screen/check_list.dart';
import 'package:icebergnote/screen/search_screen.dart';
import 'package:realm/realm.dart';
import 'dart:ui' as ui;

import '../main.dart';
import '../notes.dart';
import 'input_screen.dart';
import 'noteslist_screen.dart';

class StarPage extends StatefulWidget {
  const StarPage({super.key, required this.mod, required this.txt});
  final String txt;
  final int mod;

  @override
  StarPageState createState() => StarPageState();
}

class StarPageState extends State<StarPage> {
  final ScrollController _scrollController = ScrollController();
  var searchnotesList = NotesList();
  String searchText = '';
  late String time;

  void refreshList() {
    double scrollPosition = _scrollController.position.pixels;
    setState(() {
      searchnotesList.searchStar(searchText, 0);

      _scrollController.jumpTo(scrollPosition);
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);

    searchnotesList.searchStar(searchText, 0);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      setState(() {
        searchnotesList.searchStar(searchText, 50);

        refreshList();
      });
    }
    if (_scrollController.position.pixels == 0 && widget.mod == 0) {
      setState(() {
        searchnotesList.searchStar(searchText, 0);
      });
    }
  }

  Widget buildCard(Notes note) {
    if (note.noteType == '.TODO' ||
        note.noteType == '.todo' ||
        note.noteType == '.待办' ||
        note.noteType == '.Todo') {
      return Card(
        color: note.noteFinishState == '已完'
            ? const Color.fromARGB(20, 200, 200, 200)
            : const Color.fromARGB(20, 0, 123, 128),
        margin: const EdgeInsets.fromLTRB(15, 0, 15, 10),
        elevation: 0,
        shadowColor: Theme.of(context).primaryColor,
        child: ListTile(
          minVerticalPadding: 1,
          title: CheckboxListTile(
            title: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangePage(
                      onPageClosed: () {
                        refreshList();
                      },
                      note: note,
                      mod: 1,
                    ),
                  ),
                );
              },
              child: Text(
                note.noteTitle,
                style: TextStyle(
                  color: note.noteFinishState == '已完'
                      ? const Color.fromARGB(255, 200, 200, 200)
                      : const Color.fromARGB(255, 0, 123, 128),
                  decoration: note.noteFinishState == '已完'
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  fontSize: 18,
                ),
              ),
            ),
            value: note.noteFinishState == '已完',
            onChanged: (value) {
              if (value == true) {
                setState(() {
                  realm.write(() {
                    note.noteFinishState = '已完';
                    note.noteFinishDate = DateTime.now().toUtc();
                    note.noteUpdateDate = DateTime.now().toUtc();
                  });
                });
              } else {
                realm.write(() {
                  setState(() {
                    note.noteFinishState = '未完';
                    note.noteUpdateDate = DateTime.now().toUtc();
                  });
                });
              }
            },
          ),
          subtitle: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                visible: note.noteContext != "",
                child: Text(
                  note.noteContext,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChangePage(
                  onPageClosed: () {
                    refreshList();
                  },
                  note: note,
                  mod: 1,
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
                    note: note,
                    onDialogClosed: () {
                      refreshList();
                    },
                  );
                } else {
                  return BottomPopSheet(
                    note: note,
                    onDialogClosed: () {
                      refreshList();
                    },
                  );
                }
              },
            );
          },
        ),
      );
    } else if (note.noteType == '.记录' &&
        recordTemplates[note.noteProject] != null &&
        recordTemplatesSettings[note.noteProject] != null) {
      // var templateNote = realm.query<Notes>(
      //     "noteType == \$0 AND noteProject == \$1 AND noteIsDeleted != true SORT(noteCreateDate DESC) LIMIT(1)",
      //     [
      //       '.表单',
      //       note.noteProject,
      //     ])[0];

      // if (note.noteContext == '') {
      //   realm.write(() {
      //     note.noteContext =
      //         templateNote.noteContext.replaceAll(RegExp(r': .*'), ': ');
      //   });
      // }
      if (recordTemplatesSettings[note.noteProject]!['卡片'] != null) {
        List<int> properties = [];
        for (int i = 0;
            i < recordTemplatesSettings[note.noteProject]!['卡片']!.length;
            i++) {
          int? tmp = int.tryParse(
              recordTemplatesSettings[note.noteProject]!['卡片']![i]);
          if (tmp != null) {
            properties.add(tmp);
          }
        }
        return buildRecordCardOfList(
            note, widget.mod, context, refreshList, properties);
      } else {
        return buildRecordCardOfList(note, widget.mod, context, refreshList,
            recordTemplates[note.noteProject]!.keys.toList());
      }
      // return Card(
      //   margin: const EdgeInsets.fromLTRB(15, 0, 15, 10),
      //   elevation: 0,
      //   shadowColor: const Color.fromARGB(255, 255, 132, 132),
      //   color: backgroundColor,
      //   child: ListTile(
      //     title: SizedBox(
      //       height: 40,
      //       child: Text(
      //         '${note.noteProject}  ${propertySettings1[2] ?? ''}${noteMap[noteMap.keys.first] ?? ''}${propertySettings1[3] ?? ''}',
      //         maxLines: 1,
      //         overflow: TextOverflow.fade,
      //         style: TextStyle(
      //           fontSize: 20,
      //           fontWeight: FontWeight.w600,
      //           color: fontColor,
      //         ),
      //       ),
      //     ),
      //     subtitle: Wrap(
      //       spacing: 5,
      //       runSpacing: 5,
      //       children: List.generate(
      //         noteMapOther.length,
      //         (index) {
      //           List propertySettings = ['', '', '', ''];
      //           if (template.containsKey(noteMapOther.keys.elementAt(index))) {
      //             propertySettings =
      //                 template[noteMapOther.keys.elementAt(index)].split(",");
      //           }
      //           if (noteMapOther.values.elementAt(index) != null) {
      //             switch (propertySettings[1]) {
      //               case '长文':
      //                 return Row(
      //                   crossAxisAlignment: CrossAxisAlignment.baseline,
      //                   textBaseline: TextBaseline.ideographic,
      //                   children: [
      //                     Container(
      //                       margin: const EdgeInsets.all(0),
      //                       padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      //                       decoration: BoxDecoration(
      //                         borderRadius: BorderRadius.circular(4),
      //                         color: fontColor,
      //                       ),
      //                       child: Text(
      //                         "${propertySettings[0] ?? ''}",
      //                         style: const TextStyle(
      //                           fontFamily: 'LXGWWenKai',
      //                           fontSize: 16,
      //                           fontWeight: FontWeight.w600,
      //                           color: Colors.white,
      //                         ),
      //                       ),
      //                     ),
      //                     Text(
      //                       " : ",
      //                       style: TextStyle(
      //                         fontFamily: 'LXGWWenKai',
      //                         fontSize: 16,
      //                         fontWeight: FontWeight.w600,
      //                         color: fontColor,
      //                       ),
      //                     ),
      //                     Expanded(
      //                       child: Text(
      //                         '${propertySettings[2] ?? ''}${noteMapOther.values.elementAt(index).toString().replaceAll('    ', '\n')}${propertySettings[3] ?? ''}',
      //                         style: TextStyle(
      //                           fontSize: 16,
      //                           fontWeight: FontWeight.w600,
      //                           color: fontColor,
      //                         ),
      //                       ),
      //                     ),
      //                   ],
      //                 );
      //               case '单选':
      //               case '多选':
      //                 List selectedlist = noteMapOther.values
      //                     .elementAt(index)
      //                     .toString()
      //                     .split(', ');
      //                 return Row(
      //                   mainAxisSize: MainAxisSize.max,
      //                   crossAxisAlignment: CrossAxisAlignment.start,
      //                   children: [
      //                     Container(
      //                       margin: const EdgeInsets.all(0),
      //                       padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      //                       decoration: BoxDecoration(
      //                         borderRadius: BorderRadius.circular(4),
      //                         color: fontColor,
      //                       ),
      //                       child: Text(
      //                         "${propertySettings[0] ?? ''}",
      //                         style: const TextStyle(
      //                           fontFamily: 'LXGWWenKai',
      //                           fontSize: 16,
      //                           fontWeight: FontWeight.w600,
      //                           color: Colors.white,
      //                         ),
      //                       ),
      //                     ),
      //                     Text(
      //                       " : ",
      //                       style: TextStyle(
      //                         fontFamily: 'LXGWWenKai',
      //                         fontSize: 16,
      //                         fontWeight: FontWeight.w600,
      //                         color: fontColor,
      //                       ),
      //                     ),
      //                     Expanded(
      //                       child: Wrap(
      //                         runSpacing: 5,
      //                         children: List.generate(
      //                           selectedlist.length,
      //                           (index) {
      //                             return Container(
      //                               margin:
      //                                   const EdgeInsets.fromLTRB(0, 0, 5, 0),
      //                               padding:
      //                                   const EdgeInsets.fromLTRB(5, 0, 5, 0),
      //                               decoration: BoxDecoration(
      //                                 borderRadius: BorderRadius.circular(20),
      //                                 color: fontColor,
      //                               ),
      //                               child: Text(
      //                                 selectedlist[index],
      //                                 style: const TextStyle(
      //                                   fontFamily: 'LXGWWenKai',
      //                                   fontSize: 16,
      //                                   fontWeight: FontWeight.w600,
      //                                   color: Colors.white,
      //                                 ),
      //                               ),
      //                             );
      //                           },
      //                         ),
      //                       ),
      //                     ),
      //                   ],
      //                 );
      //               case '时间':
      //                 return Row(
      //                   mainAxisSize: MainAxisSize.max,
      //                   children: [
      //                     Container(
      //                       margin: const EdgeInsets.all(0),
      //                       padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      //                       decoration: BoxDecoration(
      //                         borderRadius: BorderRadius.circular(4),
      //                         color: fontColor,
      //                       ),
      //                       child: Text(
      //                         "${propertySettings[0] ?? ''}",
      //                         style: const TextStyle(
      //                           fontFamily: 'LXGWWenKai',
      //                           fontSize: 16,
      //                           fontWeight: FontWeight.w600,
      //                           color: Colors.white,
      //                         ),
      //                       ),
      //                     ),
      //                     Text(
      //                       noteMapOther.values
      //                                   .elementAt(index)
      //                                   .toString()[0] !=
      //                               '0'
      //                           ? ' : ${propertySettings[2] ?? ''}${noteMapOther.values.elementAt(index).toString()}${propertySettings[3] ?? ''}'
      //                           : ' : ${propertySettings[2] ?? ''}${noteMapOther.values.elementAt(index).toString().substring(2).replaceAll(':', '′')}″${propertySettings[3] ?? ''}',
      //                       style: TextStyle(
      //                         fontFamily: 'LXGWWenKai',
      //                         fontSize: 16,
      //                         fontWeight: FontWeight.w600,
      //                         color: fontColor,
      //                       ),
      //                     ),
      //                   ],
      //                 );
      //               case '时长':
      //                 Duration? duration = stringToDuration(
      //                     noteMapOther.values.elementAt(index).toString());
      //                 if (duration == null) {
      //                   return Row(
      //                     mainAxisSize: MainAxisSize.max,
      //                     children: [
      //                       Container(
      //                         margin: const EdgeInsets.all(0),
      //                         padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      //                         decoration: BoxDecoration(
      //                           borderRadius: BorderRadius.circular(4),
      //                           color: fontColor,
      //                         ),
      //                         child: Text(
      //                           "${propertySettings[0] ?? ''}",
      //                           style: const TextStyle(
      //                             fontFamily: 'LXGWWenKai',
      //                             fontSize: 16,
      //                             fontWeight: FontWeight.w600,
      //                             color: Colors.white,
      //                           ),
      //                         ),
      //                       ),
      //                       Text(
      //                         ' : ',
      //                         style: TextStyle(
      //                           fontFamily: 'LXGWWenKai',
      //                           fontSize: 16,
      //                           fontWeight: FontWeight.w600,
      //                           color: fontColor,
      //                         ),
      //                       ),
      //                       Text(
      //                         noteMapOther.values.elementAt(index).toString(),
      //                         style: const TextStyle(
      //                           fontFamily: 'LXGWWenKai',
      //                           fontSize: 16,
      //                           fontWeight: FontWeight.w600,
      //                           color: Colors.red,
      //                         ),
      //                       ),
      //                     ],
      //                   );
      //                 } else {
      //                   return Row(
      //                     mainAxisSize: MainAxisSize.max,
      //                     children: [
      //                       Container(
      //                         margin: const EdgeInsets.all(0),
      //                         padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      //                         decoration: BoxDecoration(
      //                           borderRadius: BorderRadius.circular(4),
      //                           color: fontColor,
      //                         ),
      //                         child: Text(
      //                           "${propertySettings[0] ?? ''}",
      //                           style: const TextStyle(
      //                             fontFamily: 'LXGWWenKai',
      //                             fontSize: 16,
      //                             fontWeight: FontWeight.w600,
      //                             color: Colors.white,
      //                           ),
      //                         ),
      //                       ),
      //                       Text(
      //                         ' : ${duration.inDays == 0 ? '' : '${duration.inDays}天'}${duration.inHours == 0 ? '' : '${duration.inHours % 24}时'}${duration.inMinutes == 0 ? '' : '${duration.inMinutes % 60}分'}${duration.inSeconds == 0 ? '' : '${duration.inSeconds % 60}秒'}',
      //                         style: TextStyle(
      //                           fontFamily: 'LXGWWenKai',
      //                           fontSize: 16,
      //                           fontWeight: FontWeight.w600,
      //                           color: fontColor,
      //                         ),
      //                       ),
      //                     ],
      //                   );
      //                 }
      //               case '数字':
      //                 double? number = double.tryParse(
      //                     noteMapOther.values.elementAt(index).toString());
      //                 return Row(
      //                   mainAxisSize: MainAxisSize.max,
      //                   children: [
      //                     Container(
      //                       margin: const EdgeInsets.all(0),
      //                       padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      //                       decoration: BoxDecoration(
      //                         borderRadius: BorderRadius.circular(4),
      //                         color: fontColor,
      //                       ),
      //                       child: Text(
      //                         "${propertySettings[0] ?? ''}",
      //                         style: const TextStyle(
      //                           fontFamily: 'LXGWWenKai',
      //                           fontSize: 16,
      //                           fontWeight: FontWeight.w600,
      //                           color: Colors.white,
      //                         ),
      //                       ),
      //                     ),
      //                     Text(
      //                       ' : ${propertySettings[2] ?? ''}${noteMapOther.values.elementAt(index).toString().replaceAll('    ', '\n${' ' * (propertySettings[0].runes.length * 2 + 2)}')}${propertySettings[3] ?? ''}',
      //                       style: TextStyle(
      //                         fontFamily: 'LXGWWenKai',
      //                         fontSize: 16,
      //                         fontWeight: FontWeight.w600,
      //                         color: number == null ? Colors.red : fontColor,
      //                       ),
      //                     ),
      //                   ],
      //                 );

      //               default:
      //                 return Row(
      //                   mainAxisSize: MainAxisSize.max,
      //                   children: [
      //                     Container(
      //                       margin: const EdgeInsets.all(0),
      //                       padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      //                       decoration: BoxDecoration(
      //                         borderRadius: BorderRadius.circular(4),
      //                         color: fontColor,
      //                       ),
      //                       child: Text(
      //                         "${propertySettings[0] ?? ''}",
      //                         style: const TextStyle(
      //                           fontFamily: 'LXGWWenKai',
      //                           fontSize: 16,
      //                           fontWeight: FontWeight.w600,
      //                           color: Colors.white,
      //                         ),
      //                       ),
      //                     ),
      //                     Text(
      //                       ' : ${propertySettings[2] ?? ''}${noteMapOther.values.elementAt(index).toString().replaceAll('    ', '\n${' ' * (propertySettings[0].runes.length * 2 + 2)}')}${propertySettings[3] ?? ''}',
      //                       style: TextStyle(
      //                         fontFamily: 'LXGWWenKai',
      //                         fontSize: 16,
      //                         fontWeight: FontWeight.w600,
      //                         color: fontColor,
      //                       ),
      //                     ),
      //                   ],
      //                 );
      //             }
      //           } else {
      //             return const SizedBox(height: 0, width: 0);
      //           }
      //         },
      //       ),
      //     ),
      //     onTap: () {
      //       Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //           builder: (context) => RecordChangePage(
      //             onPageClosed: () {
      //               refreshList();
      //             },
      //             note: note,
      //             mod: 1,
      //           ),
      //         ),
      //       );
      //     },
      //     onLongPress: () {
      //       showModalBottomSheet(
      //         context: context,
      //         builder: (context) {
      //           if (widget.mod == 2) {
      //             return BottomPopSheetDeleted(
      //               note: note,
      //               onDialogClosed: () {
      //                 refreshList();
      //               },
      //             );
      //           } else {
      //             return BottomPopSheet(
      //               note: note,
      //               onDialogClosed: () {
      //                 refreshList();
      //               },
      //             );
      //           }
      //         },
      //       );
      //     },
      //   ),
      // );
    } else if (note.noteType == '.清单') {
      List<Todo> todoList = stringToTodoList(note.noteContext);
      Color fontColor = const Color.fromARGB(255, 48, 207, 121);
      Color backgroundColor = const Color.fromARGB(20, 48, 207, 121);
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
                Visibility(
                  visible: note.noteTitle != "",
                  child: SizedBox(
                    child: note.noteTitle.contains(searchText) &&
                            searchText != ''
                        ? buildRichText(
                            note.noteTitle,
                            searchText,
                            const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color.fromARGB(255, 0, 140, 198)),
                            TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color:
                                    const ui.Color.fromARGB(255, 0, 140, 198),
                                backgroundColor: Colors.yellow[100],
                                fontFamily: 'LXGWWenKai'),
                          )
                        : Text(
                            note.noteTitle,
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
                ),
                Visibility(
                  visible: note.noteTitle != "",
                  child: const SizedBox(
                    height: 5,
                  ),
                ),
                Visibility(
                  visible: note.noteContext != "",
                  child: note.noteContext.contains(searchText) &&
                          searchText != ''
                      ? buildRichText(
                          note.noteContext.replaceAll(RegExp('\n|/n'), '  '),
                          searchText,
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
                            (index) => Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Checkbox.adaptive(
                                  fillColor: MaterialStateProperty.all(
                                      const Color.fromARGB(0, 0, 0, 0)),
                                  checkColor: todoList[index].finishState == 3
                                      ? Colors.grey
                                      : fontColor,
                                  value: todoList[index].finishState == 1
                                      ? true
                                      : todoList[index].finishState == 0
                                          ? false
                                          : null,
                                  tristate: true,
                                  onChanged: (bool? value) {
                                    todoList[index].finishState =
                                        todoList[index].finishState + 1;
                                    if (todoList[index].finishState > 1) {
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
                                      note.noteContext =
                                          todoListToString(todoList);
                                    });
                                    setState(() {});
                                  },
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
                                Divider(
                                  color: backgroundColor,
                                  thickness: 3,
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
                Visibility(
                  visible:
                      note.noteType + note.noteProject + note.noteFolder != "",
                  child: Row(
                    children: [
                      Container(
                        width: 70,
                        padding: const EdgeInsets.all(0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          note.noteType,
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
                          note.noteProject,
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
                          note.noteFolder,
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
                  refreshList();
                },
                note: note,
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
                  note: note,
                  onDialogClosed: () {
                    refreshList();
                  },
                );
              } else {
                return BottomPopSheet(
                  note: note,
                  onDialogClosed: () {
                    refreshList();
                  },
                );
              }
            },
          );
        },
      );
    } else {
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
                Visibility(
                  visible: note.noteTitle != "",
                  child: SizedBox(
                    child: note.noteTitle.contains(searchText) &&
                            searchText != ''
                        ? buildRichText(
                            note.noteTitle,
                            searchText,
                            const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color.fromARGB(255, 0, 140, 198)),
                            TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color:
                                    const ui.Color.fromARGB(255, 0, 140, 198),
                                backgroundColor: Colors.yellow[100],
                                fontFamily: 'LXGWWenKai'),
                          )
                        : Text(
                            note.noteTitle,
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
                ),
                Visibility(
                  visible: note.noteTitle != "",
                  child: const SizedBox(
                    height: 5,
                  ),
                ),
                Visibility(
                  visible: note.noteContext != "",
                  child: note.noteContext.contains(searchText) &&
                          searchText != ''
                      ? buildRichText(
                          note.noteContext.replaceAll(RegExp('\n|/n'), '  '),
                          searchText,
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
                      : Text(
                          note.noteContext.replaceAll(RegExp('\n|/n'), '  '),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 5,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                ),
                // Text(
                //   '${note.noteContext.length + note.noteTitle.length}${note.noteCreatTime.length > 19 ? '${note.noteCreatTime.substring(0, 19)}创建       ' : note.noteCreatTime}${note.noteUpdateTime.length > 19 ? '${note.noteUpdateTime.substring(0, 19)}修改' : note.noteUpdateTime}',
                //   maxLines: 1,
                //   style: const TextStyle(
                //     fontSize: 10,
                //   ),
                // ),
                Visibility(
                  visible:
                      note.noteType + note.noteProject + note.noteFolder != "",
                  child: Row(
                    children: [
                      Container(
                        width: 70,
                        padding: const EdgeInsets.all(0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          note.noteType,
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
                          note.noteProject,
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
                          note.noteFolder,
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
              builder: (context) => ChangePage(
                onPageClosed: () {
                  refreshList();
                },
                note: note,
                mod: 1,
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
                  note: note,
                  onDialogClosed: () {
                    refreshList();
                  },
                );
              } else {
                return BottomPopSheet(
                  note: note,
                  onDialogClosed: () {
                    refreshList();
                  },
                );
              }
            },
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Notes note = Notes(
              Uuid.v4(),
              '',
              '',
              '',
              DateTime.now().toUtc(),
              DateTime.now().toUtc(),
              DateTime.utc(1970, 1, 1),
              DateTime.utc(1970, 1, 1),
              DateTime.utc(1970, 1, 1),
              DateTime.utc(1970, 1, 1),
              noteType: '.todo',
              noteFinishState: '未完',
            );
            realm.write(() {
              realm.add<Notes>(note, update: true);
            });
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChangePage(
                  onPageClosed: () {
                    refreshList();
                  },
                  note: note,
                  mod: 0,
                ),
              ),
            );
          },
          child: const Icon(Icons.add)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: searchnotesList.notesList.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onLongPress: () {
                    HapticFeedback.heavyImpact();
                  },
                  onTap: () {
                    HapticFeedback.lightImpact();
                  },
                  child: buildCard(searchnotesList.notesList[index]),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
