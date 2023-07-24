import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:realm/realm.dart';

import '../constants.dart';
import '../main.dart';
import '../notes.dart';
import 'input_screen.dart';
import 'noteslist_screen.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key, required this.mod, required this.txt});
  final String txt;
  final int mod;

  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  var searchnotesList = NotesList();
  String searchText = '';
  late String time;
  List<String> folderList = ['全部'];
  List<String> projectList = ['全部'];
  List<String> finishStateList = ['未完', '已完'];

  String searchProject = '';
  String searchFolder = '';
  String searchFinishState = '未完';

  void refreshList() {
    double scrollPosition = _scrollController.position.pixels;
    setState(() {
      searchnotesList.searchall(searchText, 0, '.todo', searchProject,
          searchFolder, searchFinishState);

      _scrollController.jumpTo(scrollPosition);
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);

    searchnotesList.searchall(
        searchText, 0, '.todo', searchProject, searchFolder, searchFinishState);

    List<Notes> folderDistinctList = realm
        .query<Notes>(
            "noteFolder !='' AND noteType == '.todo' DISTINCT(noteFolder)")
        .toList();

    for (int i = 0; i < folderDistinctList.length; i++) {
      folderList.add(folderDistinctList[i].noteFolder);
    }
    List<Notes> projectDistinctList = realm
        .query<Notes>(
            "noteProject !='' AND noteType == '.todo' DISTINCT(noteProject)")
        .toList();

    for (int i = 0; i < projectDistinctList.length; i++) {
      projectList.add(projectDistinctList[i].noteProject);
    }
    List<Notes> finishStateDistinctList = realm
        .query<Notes>(
            "noteFinishState !='' AND noteType == '.todo' DISTINCT(noteFinishState)")
        .toList();

    for (int i = 0; i < finishStateDistinctList.length; i++) {
      if ((finishStateDistinctList[i].noteFinishState != '未完') &&
          (finishStateDistinctList[i].noteFinishState != '已完')) {
        finishStateList.add(finishStateDistinctList[i].noteFinishState);
      }
    }
    finishStateList.add('全部');
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
        searchnotesList.searchall(searchText, 15, '.todo', searchProject,
            searchFolder, searchFinishState);

        refreshList();
      });
    }
    if (_scrollController.position.pixels == 0 && widget.mod == 0) {
      setState(() {
        searchnotesList.searchall(searchText, 0, '.todo', searchProject,
            searchFolder, searchFinishState);
      });
    }
  }

  Widget buildCard(Notes note) {
    if (note.noteType == '.TODO' ||
        note.noteType == '.todo' ||
        note.noteType == '.待办' ||
        note.noteType == '.Todo') {
      return Card(
        margin: const EdgeInsets.fromLTRB(30, 10, 30, 0),
        elevation: 3, // 阴影大小

        shadowColor: Theme.of(context).primaryColor,
        child: ListTile(
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
                  decoration: note.noteIsAchive
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
                    note.noteFinishTime = DateTime.now().toString();
                  });
                });
              } else {
                realm.write(() {
                  setState(() {
                    note.noteFinishState = '未完';
                    note.noteFinishTime = '';
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
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Visibility(
                visible: true,
                child: Row(
                  children: [
                    // Container(
                    //   width: 70,
                    //   padding: const EdgeInsets.all(0),
                    //   alignment: Alignment.centerLeft,
                    //   child: Text(
                    //     note.noteType,
                    //     style: const TextStyle(
                    //       fontSize: 10,
                    //     ),
                    //   ),
                    // ),
                    // Container(
                    //   padding: const EdgeInsets.all(0),
                    //   alignment: Alignment.centerLeft,
                    //   width: 79,
                    //   child: Text(
                    //     note.noteProject,
                    //     style: const TextStyle(
                    //       fontSize: 10,
                    //     ),
                    //   ),
                    // ),
                    // Container(
                    //   padding: const EdgeInsets.all(0),
                    //   alignment: Alignment.centerLeft,
                    //   width: 150,
                    //   child: Text(
                    //     note.noteFolder,
                    //     style: const TextStyle(
                    //       fontSize: 10,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              )
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
    } else {
      return Card(
        margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        elevation: 3, // 阴影大小
        shadowColor: Colors.grey,
        child: ListTile(
          title: Row(
            children: [
              Visibility(
                visible: note.noteTitle != "",
                child: Text(
                  note.noteTitle,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
          subtitle: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                visible: note.noteContext != "",
                child: Text(
                  note.noteContext,
                  maxLines: 5,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${note.noteContext.length + note.noteTitle.length}${note.noteCreatTime.length > 19 ? '${note.noteCreatTime.substring(0, 19)}创建       ' : note.noteCreatTime}${note.noteUpdateTime.length > 19 ? '${note.noteUpdateTime.substring(0, 19)}修改' : note.noteUpdateTime}',
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 10,
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
                        ),
                      ),
                    ),
                  ],
                ),
              )
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Notes note = Notes(
              ObjectId(),
              '',
              '',
              '',
              noteCreatTime: DateTime.now().toString(),
              noteType: '.todo',
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Row(
          children: [
            const SizedBox(
              width: 30,
            ),
            // const Text(
            //   '待办',
            //   style: TextStyle(
            //     color: Color.fromARGB(255, 56, 128, 186),
            //     fontSize: 20,
            //   ),
            // ),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: '搜索',
                  border: UnderlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(
                    () {
                      searchText = value;
                      searchnotesList.searchall(searchText, 0, '.todo',
                          searchProject, searchFolder, searchFinishState);
                      refreshList();
                    },
                  );
                },
              ),
            ),
            MenuAnchor(
              builder: (context, controller, child) {
                return FilledButton.tonal(
                  style: selectButtonStyle,
                  onPressed: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                  child: Text(
                    searchProject == '' ? '项目' : searchProject,
                    style: searchProject == ''
                        ? const TextStyle(color: Colors.grey)
                        : const TextStyle(
                            color: Color.fromARGB(255, 215, 55, 55)),
                  ),
                );
              },
              menuChildren: projectList.map((project) {
                return MenuItemButton(
                  child: Text(project),
                  onPressed: () {
                    if (project == '全部') {
                      searchProject = '';
                    } else {
                      searchProject = project;
                    }
                    refreshList();
                  },
                );
              }).toList(),
            ),
            const SizedBox(
              width: 5,
            ),
            MenuAnchor(
              builder: (context, controller, child) {
                return FilledButton.tonal(
                  style: selectButtonStyle,
                  onPressed: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                  child: Text(
                    searchFolder == '' ? '路径' : searchFolder,
                    style: searchFolder == ''
                        ? const TextStyle(color: Colors.grey)
                        : const TextStyle(
                            color: Color.fromARGB(255, 4, 123, 60)),
                  ),
                );
              },
              menuChildren: folderList.map((folder) {
                return MenuItemButton(
                  child: Text(folder),
                  onPressed: () {
                    if (folder == '全部') {
                      searchFolder = '';
                    } else {
                      searchFolder = folder;
                    }
                    refreshList();
                  },
                );
              }).toList(),
            ),
            const SizedBox(
              width: 5,
            ),
            MenuAnchor(
              builder: (context, controller, child) {
                return FilledButton.tonal(
                  style: selectButtonStyle,
                  onPressed: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                  child: Text(
                    searchFinishState == '' ? '全部' : searchFinishState,
                    style: searchFinishState == ''
                        ? const TextStyle(color: Colors.grey)
                        : const TextStyle(
                            color: Color.fromARGB(255, 139, 78, 236)),
                  ),
                );
              },
              menuChildren: finishStateList.map((finishState) {
                return MenuItemButton(
                  child: Text(finishState),
                  onPressed: () {
                    if (finishState == '全部') {
                      searchFinishState = '';
                    } else {
                      searchFinishState = finishState;
                    }
                    refreshList();
                  },
                );
              }).toList(),
            ),
            const SizedBox(
              width: 30,
            ),
          ],
        ),
      ),
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

// class TodoPage extends StatefulWidget {
//   const TodoPage({super.key, required this.mod, required this.txt});
//   final String txt;
//   final int mod;
//   @override
//   _TodoPageState createState() => _TodoPageState();
// }

// class _TodoPageState extends State<TodoPage> {
//   final TextEditingController _searchController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   var searchnotesList = NotesList();
//   String searchText = '';
//   late String time;
//   void refreshList() {
//     double scrollPosition = _scrollController.position.pixels;
//     setState(() {
//       switch (widget.mod) {
//         case 0:
//           searchnotesList.search(searchText, 0);
//           break;
//         case 1:
//           searchnotesList.search(searchText, 0);
//           break;
//         case 2:
//           searchnotesList.searchDeleted(searchText, 0);
//           break;
//         case 3:
//           searchnotesList.searchTodo(searchText, 0);
//           break;
//       }
//       _scrollController.jumpTo(scrollPosition);
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     _scrollController.addListener(_scrollListener);
//     switch (widget.mod) {
//       case 0:
//         searchnotesList.search(searchText, 0);
//         break;
//       case 1:
//         searchnotesList.search(searchText, 0);
//         break;
//       case 2:
//         searchnotesList.searchDeleted(searchText, 0);
//         break;
//       case 3:
//         searchnotesList.searchTodo(searchText, 0);
//         break;
//     }
//   }

//   @override
//   void dispose() {
//     _scrollController.removeListener(_scrollListener);
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _scrollListener() {
//     if (_scrollController.position.pixels ==
//         _scrollController.position.maxScrollExtent) {
//       setState(() {
//         switch (widget.mod) {
//           case 0:
//             searchnotesList.search(searchText, 15);
//             break;
//           case 1:
//             searchnotesList.search(searchText, 15);
//             break;
//           case 2:
//             searchnotesList.searchDeleted(searchText, 15);
//             break;
//           case 3:
//             searchnotesList.searchTodo(searchText, 15);
//             break;
//         }
//         refreshList();
//       });
//     }
//     if (_scrollController.position.pixels == 0 && widget.mod == 0) {
//       setState(() {
//         switch (widget.mod) {
//           case 0:
//             searchnotesList.search(searchText, 0);
//             break;
//           case 1:
//             searchnotesList.search(searchText, 0);
//             break;
//           case 2:
//             searchnotesList.searchDeleted(searchText, 0);
//             break;
//           case 3:
//             searchnotesList.searchTodo(searchText, 0);
//             break;
//         }
//       });
//     }
//   }

//   PreferredSizeWidget buildAppBar() {
//     if (widget.mod == 0) {
//       return AppBar(
//         title: Row(
//           children: [
//             const Expanded(
//               child: TimeBar(),
//             ),
//             IconButton(
//               onPressed: () {
//                 // TODO:时间记录
//               },
//               icon: const Icon(
//                 Icons.add_alarm,
//               ),
//             ),
//           ],
//         ),
//       );
//     } else if (widget.mod == 1) {
//       return AppBar(title: const Text("搜索"));
//     } else if (widget.mod == 3) {
//       return AppBar(title: const Text("待办"));
//     } else {
//       return AppBar(title: const Text("回收站"));
//     }
//   }

//   Widget buildCard(Notes note) {
//     if (note.noteType == '.TODO' ||
//         note.noteType == '.todo' ||
//         note.noteType == '.待办' ||
//         note.noteType == '.Todo') {
//       return Card(
//         margin: const EdgeInsets.fromLTRB(30, 10, 30, 0),
//         elevation: 3, // 阴影大小

//         shadowColor: Theme.of(context).primaryColor,
//         child: ListTile(
//           title: CheckboxListTile(
//               title: GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => ChangePage(
//                         onPageClosed: () {
//                           refreshList();
//                         },
//                         note: note,
//                         mod: 1,
//                       ),
//                     ),
//                   );
//                 },
//                 child: Text(
//                   note.noteTitle,
//                   style: TextStyle(
//                     decoration: note.noteIsAchive
//                         ? TextDecoration.lineThrough
//                         : TextDecoration.none,
//                     fontSize: 18,
//                   ),
//                 ),
//               ),
//               value: note.noteIsAchive,
//               onChanged: (value) {
//                 if (value == true) {
//                   realm.write(() {
//                     note.noteIsAchive = value!;
//                     note.noteAchiveTime = DateTime.now().toString();
//                   });
//                 } else {
//                   realm.write(() {
//                     note.noteIsAchive = value!;
//                     note.noteAchiveTime = '';
//                   });
//                 }
//                 setState(() {});
//               }),
//           subtitle: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Visibility(
//                 visible: note.noteContext != "",
//                 child: Text(
//                   note.noteContext,
//                   style: const TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               const Visibility(
//                 visible: true,
//                 child: Row(
//                   children: [
//                     // Container(
//                     //   width: 70,
//                     //   padding: const EdgeInsets.all(0),
//                     //   alignment: Alignment.centerLeft,
//                     //   child: Text(
//                     //     note.noteType,
//                     //     style: const TextStyle(
//                     //       fontSize: 10,
//                     //     ),
//                     //   ),
//                     // ),
//                     // Container(
//                     //   padding: const EdgeInsets.all(0),
//                     //   alignment: Alignment.centerLeft,
//                     //   width: 79,
//                     //   child: Text(
//                     //     note.noteProject,
//                     //     style: const TextStyle(
//                     //       fontSize: 10,
//                     //     ),
//                     //   ),
//                     // ),
//                     // Container(
//                     //   padding: const EdgeInsets.all(0),
//                     //   alignment: Alignment.centerLeft,
//                     //   width: 150,
//                     //   child: Text(
//                     //     note.noteFolder,
//                     //     style: const TextStyle(
//                     //       fontSize: 10,
//                     //     ),
//                     //   ),
//                     // ),
//                   ],
//                 ),
//               )
//             ],
//           ),
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => ChangePage(
//                   onPageClosed: () {
//                     refreshList();
//                   },
//                   note: note,
//                   mod: 1,
//                 ),
//               ),
//             );
//           },
//           onLongPress: () {
//             showModalBottomSheet(
//               context: context,
//               builder: (context) {
//                 if (widget.mod == 2) {
//                   return BottomPopSheetDeleted(
//                     note: note,
//                     onDialogClosed: () {
//                       refreshList();
//                     },
//                   );
//                 } else {
//                   return BottomPopSheet(
//                     note: note,
//                     onDialogClosed: () {
//                       refreshList();
//                     },
//                   );
//                 }
//               },
//             );
//           },
//         ),
//       );
//     } else {
//       return Card(
//         margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
//         elevation: 3, // 阴影大小
//         shadowColor: Colors.grey,
//         child: ListTile(
//           title: Row(
//             children: [
//               Visibility(
//                 visible: note.noteTitle != "",
//                 child: Text(
//                   note.noteTitle,
//                   maxLines: 1,
//                   overflow: TextOverflow.fade,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               const Spacer(),
//             ],
//           ),
//           subtitle: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Visibility(
//                 visible: note.noteContext != "",
//                 child: Text(
//                   note.noteContext,
//                   maxLines: 5,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               Text(
//                 '${note.noteContext.length + note.noteTitle.length}${note.noteCreatTime.length > 19 ? '${note.noteCreatTime.substring(0, 19)}创建       ' : note.noteCreatTime}${note.noteUpdateTime.length > 19 ? '${note.noteUpdateTime.substring(0, 19)}修改' : note.noteUpdateTime}',
//                 maxLines: 1,
//                 style: const TextStyle(
//                   fontSize: 10,
//                 ),
//               ),
//               Visibility(
//                 visible:
//                     note.noteType + note.noteProject + note.noteFolder != "",
//                 child: Row(
//                   children: [
//                     Container(
//                       width: 70,
//                       padding: const EdgeInsets.all(0),
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         note.noteType,
//                         style: const TextStyle(
//                           fontSize: 10,
//                         ),
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.all(0),
//                       alignment: Alignment.centerLeft,
//                       width: 79,
//                       child: Text(
//                         note.noteProject,
//                         style: const TextStyle(
//                           fontSize: 10,
//                         ),
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.all(0),
//                       alignment: Alignment.centerLeft,
//                       width: 150,
//                       child: Text(
//                         note.noteFolder,
//                         style: const TextStyle(
//                           fontSize: 10,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//             ],
//           ),
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => ChangePage(
//                   onPageClosed: () {
//                     refreshList();
//                   },
//                   note: note,
//                   mod: 1,
//                 ),
//               ),
//             );
//           },
//           onLongPress: () {
//             showModalBottomSheet(
//               context: context,
//               builder: (context) {
//                 if (widget.mod == 2) {
//                   return BottomPopSheetDeleted(
//                     note: note,
//                     onDialogClosed: () {
//                       refreshList();
//                     },
//                   );
//                 } else {
//                   return BottomPopSheet(
//                     note: note,
//                     onDialogClosed: () {
//                       refreshList();
//                     },
//                   );
//                 }
//               },
//             );
//           },
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       floatingActionButton: FloatingActionButton(
//           onPressed: () {
//             Notes note = Notes(
//               ObjectId(),
//               '',
//               '',
//               '',
//               noteCreatTime: DateTime.now().toString(),
//               noteType: '.todo',
//             );
//             realm.write(() {
//               realm.add<Notes>(note, update: true);
//             });
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => ChangePage(
//                   onPageClosed: () {
//                     refreshList();
//                   },
//                   note: note,
//                   mod: 0,
//                 ),
//               ),
//             );
//           },
//           child: const Icon(Icons.add)),
//       appBar: buildAppBar(),
//       body: Column(
//         children: [
//           Offstage(
//             offstage: widget.mod == 0,
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
//               child: Center(
//                 child: TextField(
//                     controller: _searchController,
//                     decoration: const InputDecoration(
//                       hintText: '输入内容',
//                       border: OutlineInputBorder(),
//                     ),
//                     onChanged: (value) {
//                       setState(() {
//                         searchText = value;
//                         switch (widget.mod) {
//                           case 0:
//                             searchnotesList.search(searchText, 0);
//                             break;
//                           case 1:
//                             searchnotesList.search(searchText, 0);
//                             break;
//                           case 2:
//                             searchnotesList.searchDeleted(searchText, 0);
//                             break;
//                           case 3:
//                             searchnotesList.searchTodo(searchText, 0);
//                             break;
//                         }
//                         refreshList();
//                       });
//                     }),
//               ),
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               controller: _scrollController,
//               itemCount: searchnotesList.notesList.length,
//               itemBuilder: (context, index) {
//                 return GestureDetector(
//                   onLongPress: () {
//                     HapticFeedback.heavyImpact();
//                   },
//                   onTap: () {
//                     HapticFeedback.lightImpact();
//                   },
//                   child: buildCard(searchnotesList.notesList[index]),
//                 );
//               },
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
