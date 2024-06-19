import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icebergnote/screen/card/check_list_card.dart';
import 'package:icebergnote/screen/card/normal_card.dart';
import 'package:icebergnote/screen/card/todo_card.dart';
import 'package:realm/realm.dart';

import '../constants.dart';
import '../main.dart';
import '../class/notes.dart';
import 'input/input_screen.dart';
import 'noteslist_screen.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key, required this.mod, required this.txt});
  final String txt;
  final int mod;

  @override
  TodoPageState createState() => TodoPageState();
}

class TodoPageState extends State<TodoPage> {
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
      searchnotesList.searchallTodo(searchText, 0, '(.todo)|(.清单)',
          searchProject, searchFolder, searchFinishState);

      _scrollController.jumpTo(scrollPosition);
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);

    searchnotesList.searchallTodo(
        searchText, 0, '.todo', searchProject, searchFolder, searchFinishState);

    List<Notes> folderDistinctList = realm
        .query<Notes>(
            "noteFolder !='' AND noteType == '.todo' DISTINCT(noteFolder) SORT(noteCreateDate DESC)")
        .toList();

    for (int i = 0; i < folderDistinctList.length; i++) {
      folderList.add(folderDistinctList[i].noteFolder);
    }
    List<Notes> projectDistinctList = realm
        .query<Notes>(
            "noteProject !='' AND noteType == '.todo' DISTINCT(noteProject) SORT(noteCreateDate DESC)")
        .toList();

    for (int i = 0; i < projectDistinctList.length; i++) {
      projectList.add(projectDistinctList[i].noteProject);
    }
    List<Notes> finishStateDistinctList = realm
        .query<Notes>(
            "noteFinishState !='' AND noteType == '.todo' DISTINCT(noteFinishState) SORT(noteCreateDate DESC)")
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
        searchnotesList.searchallTodo(searchText, 50, '.todo', searchProject,
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

  Widget buildCard(Notes note, int mod) {
    if (note.noteType == '.TODO' ||
        note.noteType == '.todo' ||
        note.noteType == '.待办' ||
        note.noteType == '.Todo') {
      return TodoCard(
        note: note,
        mod: mod,
        context: context,
        refreshList: refreshList,
        searchText: searchText,
      );
    } else if (note.noteType == '.清单') {
      return CheckListCard(
        note: note,
        mod: mod,
        context: context,
        refreshList: refreshList,
        searchText: searchText,
      );
    } else {
      return NormalCard(
        note: note,
        mod: mod,
        context: context,
        refreshList: refreshList,
        searchText: searchText,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: GestureDetector(
          onLongPress: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return BottomNoteTypeSheet(
                  noteTypeList: defaultAddTypeList,
                  onDialogClosed: () {
                    refreshList();
                  },
                );
              },
            );
          },
          child: FloatingActionButton(
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
              child: const Icon(Icons.add))),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Row(
          children: [
            const SizedBox(
              width: 30,
            ),
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
                  style: menuChildrenButtonStyle,
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
                  style: menuChildrenButtonStyle,
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
                  style: menuChildrenButtonStyle,
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
                  child: buildCard(searchnotesList.notesList[index], 0),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
