import 'package:flutter/material.dart';
import 'package:icebergnote/class/anniversary_class.dart';
import 'package:icebergnote/notes.dart';
import 'package:icebergnote/screen/input/anniversary_input.dart';
import '../noteslist_screen.dart';

class AnniversaryCard extends StatefulWidget {
  const AnniversaryCard(
      {super.key,
      required this.note,
      required this.anniversary,
      required this.mod,
      required this.context,
      required this.refreshList,
      required this.searchText});

  final Notes note;
  final Anniversary anniversary;
  final int mod;
  final BuildContext context;
  final VoidCallback refreshList;
  final String searchText;
  @override
  State<AnniversaryCard> createState() => AnniversaryCardState();
}

class AnniversaryCardState extends State<AnniversaryCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int? days;
    switch (widget.anniversary.alarmType) {
      case 0:
        days = widget.anniversary.getDays();
        break;
      case 1:
        days = widget.anniversary.getDurationDays();
        break;
      case 2:
        days = widget.anniversary.getSpecialDaysNum();
        break;
    }

    return GestureDetector(
      child: Card(
        margin: const EdgeInsets.fromLTRB(15, 0, 15, 10),
        elevation: 0,
        shadowColor: Colors.grey,
        color: widget.anniversary.bgColor,
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
                        widget.anniversary.title,
                        style: TextStyle(
                            color: widget.anniversary.fontColor, fontSize: 22),
                      ),
                      Text(widget.anniversary.date.toString().substring(0, 10),
                          style: TextStyle(
                              color: widget.anniversary.fontColor,
                              fontSize: 12))
                    ],
                  ),
                  Expanded(child: Container(height: 54)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      days != null
                          ? widget.anniversary.alarmType == 0
                              ? Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.ideographic,
                                  children: [
                                    Text(
                                      days >= 0
                                          ? widget.anniversary.oldPrefix
                                          : widget.anniversary.futurePrefix,
                                      style: TextStyle(
                                          color: widget.anniversary.fontColor,
                                          fontSize: 16),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      days.abs().toString(),
                                      style: TextStyle(
                                          color: widget.anniversary.fontColor,
                                          fontSize: 26),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      days >= 0
                                          ? widget.anniversary.oldSuffix
                                          : widget.anniversary.futureSuffix,
                                      style: TextStyle(
                                          color: widget.anniversary.fontColor,
                                          fontSize: 16),
                                    ),
                                  ],
                                )
                              : widget.anniversary.alarmType == 1
                                  ? Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.ideographic,
                                      children: [
                                        Text(
                                          widget.anniversary.futurePrefix,
                                          style: TextStyle(
                                              color:
                                                  widget.anniversary.fontColor,
                                              fontSize: 16),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          days.toString(),
                                          style: TextStyle(
                                              color:
                                                  widget.anniversary.fontColor,
                                              fontSize: 26),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          widget.anniversary.futureSuffix,
                                          style: TextStyle(
                                              color:
                                                  widget.anniversary.fontColor,
                                              fontSize: 16),
                                        ),
                                      ],
                                    )
                                  : widget.anniversary.alarmType == 2
                                      ? Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.baseline,
                                          textBaseline:
                                              TextBaseline.ideographic,
                                          children: [
                                            Text(
                                              days > 0
                                                  ? widget.anniversary.oldPrefix
                                                  : widget
                                                      .anniversary.futurePrefix,
                                              style: TextStyle(
                                                  color: widget
                                                      .anniversary.fontColor,
                                                  fontSize: 16),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              days.abs().toString(),
                                              style: TextStyle(
                                                  color: widget
                                                      .anniversary.fontColor,
                                                  fontSize: 26),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              days > 0
                                                  ? widget.anniversary.oldSuffix
                                                  : widget
                                                      .anniversary.futureSuffix,
                                              style: TextStyle(
                                                  color: widget
                                                      .anniversary.fontColor,
                                                  fontSize: 16),
                                            ),
                                          ],
                                        )
                                      : Text(
                                          'ERROR',
                                          style: TextStyle(
                                              color:
                                                  widget.anniversary.fontColor,
                                              fontSize: 16),
                                        )
                          : Text(
                              'ERROR',
                              style: TextStyle(
                                  color: widget.anniversary.fontColor,
                                  fontSize: 16),
                            ),
                      widget.anniversary.alarmType == 2
                          ? Text(
                              '距 ${widget.anniversary.alarmSpecialDate.toString().substring(0, 10)}   ${widget.anniversary.alarmSpecialDay}天',
                              style: TextStyle(
                                  color: widget.anniversary.fontColor,
                                  fontSize: 12))
                          : Container()
                    ],
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
        if (widget.mod == 5) {
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnniversaryInputPage(
                onPageClosed: () {
                  widget.refreshList();
                },
                note: widget.note,
                mod: 0,
                anniversary: widget.anniversary,
              ),
            ),
          );
        }
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
