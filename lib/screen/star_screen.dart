import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icebergnote/card.dart';
import 'package:icebergnote/class/anniversary_class.dart';
import 'package:icebergnote/constants.dart';
import 'package:icebergnote/screen/card/anniversary_card.dart';
import 'package:icebergnote/screen/card/check_list_card.dart';
import 'package:icebergnote/screen/card/todo_card.dart';
import 'package:icebergnote/screen/card/normal_card.dart';
import 'package:icebergnote/screen/richtext/richtext_card.dart';
import 'package:realm/realm.dart';

import '../main.dart';
import '../class/notes.dart';
import 'input/input_screen.dart';
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
      return TodoCard(
        note: note,
        mod: widget.mod,
        context: context,
        refreshList: refreshList,
        searchText: searchText,
      );
    } else if (note.noteType == '.记录' &&
        recordTemplates[note.noteProject] != null &&
        recordTemplatesSettings[note.noteProject] != null) {
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
    } else if (note.noteType == '.清单') {
      return CheckListCard(
        note: note,
        mod: widget.mod,
        context: context,
        refreshList: refreshList,
        searchText: searchText,
      );
    } else if (note.noteType == '.日子') {
      DateTime now = DateTime.now();
      Anniversary anniversary = Anniversary(
          date: DateTime(now.year, now.month, now.day),
          alarmSpecialDate: DateTime(now.year, now.month, now.day));
      if (note.noteContext != '') {
        anniversary = Anniversary.fromJson(jsonDecode(note.noteContext));
      } else {
        realm.write(() {
          note.noteTitle = anniversary.title;
          note.noteContext = jsonEncode(anniversary.toJson());
          note.noteUpdateDate = DateTime.now().toUtc();
        });
      }
      return AnniversaryCard(
        note: note,
        mod: widget.mod,
        context: context,
        refreshList: refreshList,
        searchText: searchText,
        anniversary: anniversary,
      );
    } else if (note.noteType == '.图文') {
      return RichtextCard(
        note: note,
        mod: widget.mod,
        context: context,
        refreshList: refreshList,
        searchText: searchText,
      );
    } else {
      return NormalCard(
        note: note,
        mod: widget.mod,
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
