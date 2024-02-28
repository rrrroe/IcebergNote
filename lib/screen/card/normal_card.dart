import 'package:flutter/material.dart';
import 'package:icebergnote/main.dart';
import 'package:icebergnote/notes.dart';
import 'package:icebergnote/screen/input_screen.dart';
import '../noteslist_screen.dart';

class NormalCard extends StatefulWidget {
  const NormalCard(
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
  State<NormalCard> createState() => NormalCardState();
}

class NormalCardState extends State<NormalCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.note.noteFinishState == '已完'
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
                      widget.refreshList();
                    },
                    note: widget.note,
                    mod: 1,
                  ),
                ),
              );
            },
            child: Text(
              widget.note.noteTitle,
              style: TextStyle(
                color: widget.note.noteFinishState == '已完'
                    ? const Color.fromARGB(255, 200, 200, 200)
                    : const Color.fromARGB(255, 0, 123, 128),
                decoration: widget.note.noteFinishState == '已完'
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                fontSize: 18,
              ),
            ),
          ),
          value: widget.note.noteFinishState == '已完',
          onChanged: (value) {
            if (value == true) {
              setState(() {
                realm.write(() {
                  widget.note.noteFinishState = '已完';
                  widget.note.noteFinishDate = DateTime.now().toUtc();
                  widget.note.noteUpdateDate = DateTime.now().toUtc();
                });
              });
            } else {
              realm.write(() {
                setState(() {
                  widget.note.noteFinishState = '未完';
                  widget.note.noteUpdateDate = DateTime.now().toUtc();
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
              visible: widget.note.noteContext != "",
              child: Text(
                widget.note.noteContext,
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
                  widget.refreshList();
                },
                note: widget.note,
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
      ),
    );
  }
}
