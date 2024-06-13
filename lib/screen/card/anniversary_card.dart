import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:icebergnote/class/anniversary_class.dart';
import 'package:icebergnote/main.dart';
import 'package:icebergnote/notes.dart';
import 'package:icebergnote/screen/input/anniversary_input.dart';
import '../noteslist_screen.dart';

class AnniversaryCard extends StatefulWidget {
  const AnniversaryCard(
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
  State<AnniversaryCard> createState() => AnniversaryCardState();
}

class AnniversaryCardState extends State<AnniversaryCard> {
  Anniversary anniversary = Anniversary();
  @override
  void initState() {
    super.initState();
    if (widget.note.noteContext != '') {
      anniversary = Anniversary.fromJson(jsonDecode(widget.note.noteContext));
    } else {
      realm.write(() {
        widget.note.noteTitle = anniversary.title;
        widget.note.noteContext = jsonEncode(anniversary.toJson());
        widget.note.noteUpdateDate = DateTime.now().toUtc();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int? days;
    switch (anniversary.alarmType) {
      case 0:
        days = anniversary.getDays();
        break;
      case 1:
        days = anniversary.getDurationDays();
        break;
      case 2:
        days = anniversary.getSpecialDays();
        break;
    }

    return GestureDetector(
      child: Card(
        margin: const EdgeInsets.fromLTRB(15, 0, 15, 10),
        elevation: 0,
        shadowColor: Colors.grey,
        color: anniversary.bgColor,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        anniversary.title,
                        style: TextStyle(
                            color: anniversary.fontColor, fontSize: 22),
                      ),
                      Text(anniversary.date.toString().substring(0, 10),
                          style: TextStyle(
                              color: anniversary.fontColor, fontSize: 12))
                    ],
                  ),
                  Expanded(child: Container()),
                  days != null
                      ? anniversary.alarmType == 0
                          ? Row(
                              children: [
                                Text(
                                  days >= 0
                                      ? anniversary.oldPrefix
                                      : anniversary.futurePrefix,
                                  style: TextStyle(
                                      color: anniversary.fontColor,
                                      fontSize: 16),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  days.abs().toString(),
                                  style: TextStyle(
                                      color: anniversary.fontColor,
                                      fontSize: 22),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  days >= 0
                                      ? anniversary.oldSuffix
                                      : anniversary.futureSuffix,
                                  style: TextStyle(
                                      color: anniversary.fontColor,
                                      fontSize: 16),
                                ),
                              ],
                            )
                          : anniversary.alarmType == 1
                              ? Row(
                                  children: [
                                    Text(
                                      anniversary.futurePrefix,
                                      style: TextStyle(
                                          color: anniversary.fontColor,
                                          fontSize: 16),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      days.toString(),
                                      style: TextStyle(
                                          color: anniversary.fontColor,
                                          fontSize: 22),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      anniversary.futureSuffix,
                                      style: TextStyle(
                                          color: anniversary.fontColor,
                                          fontSize: 16),
                                    ),
                                  ],
                                )
                              : anniversary.alarmType == 2
                                  ? Row(
                                      children: [
                                        Text(
                                          days > 0
                                              ? anniversary.oldPrefix
                                              : anniversary.futurePrefix,
                                          style: TextStyle(
                                              color: anniversary.fontColor,
                                              fontSize: 16),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          days.abs().toString(),
                                          style: TextStyle(
                                              color: anniversary.fontColor,
                                              fontSize: 22),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          days > 0
                                              ? anniversary.oldSuffix
                                              : anniversary.futureSuffix,
                                          style: TextStyle(
                                              color: anniversary.fontColor,
                                              fontSize: 16),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      'ERROR',
                                      style: TextStyle(
                                          color: anniversary.fontColor,
                                          fontSize: 16),
                                    )
                      : Text(
                          'ERROR',
                          style: TextStyle(
                              color: anniversary.fontColor, fontSize: 16),
                        ),
                  const SizedBox(width: 5),
                ],
              ),
              const SizedBox(height: 5),

              // Visibility(
              //   visible: widget.note.noteType +
              //           widget.note.noteProject +
              //           widget.note.noteFolder !=
              //       "",
              //   child: Row(
              //     children: [
              //       Container(
              //         width: 70,
              //         padding: const EdgeInsets.all(0),
              //         alignment: Alignment.centerLeft,
              //         child: Text(
              //           widget.note.noteType,
              //           style: const TextStyle(
              //             fontSize: 10,
              //             color: Color.fromARGB(255, 56, 128, 186),
              //           ),
              //         ),
              //       ),
              //       Container(
              //         padding: const EdgeInsets.all(0),
              //         alignment: Alignment.centerLeft,
              //         width: 79,
              //         child: Text(
              //           widget.note.noteProject,
              //           style: const TextStyle(
              //             fontSize: 10,
              //             color: Color.fromARGB(255, 215, 55, 55),
              //           ),
              //         ),
              //       ),
              //       Container(
              //         padding: const EdgeInsets.all(0),
              //         alignment: Alignment.centerLeft,
              //         width: 150,
              //         child: Text(
              //           widget.note.noteFolder,
              //           style: const TextStyle(
              //             fontSize: 10,
              //             color: Color.fromARGB(255, 4, 123, 60),
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnniversaryInputPage(
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
    );
  }
}
