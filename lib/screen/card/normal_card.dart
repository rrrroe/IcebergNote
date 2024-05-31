import 'package:flutter/material.dart';
import 'package:icebergnote/notes.dart';
import 'package:icebergnote/screen/input_screen.dart';
import 'package:icebergnote/screen/search_screen.dart';
import 'dart:ui' as ui;
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
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      TextPainter textPainter = TextPainter(
          maxLines: 10,
          locale: Localizations.localeOf(context),
          textAlign: TextAlign.start,
          text: TextSpan(
            text: widget.note.noteContext,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 0, 140, 198),
                fontFamily: 'LXGWWenKai'),
          ),
          textDirection: Directionality.of(context))
        ..layout(
            minWidth: constraints.minWidth, maxWidth: constraints.maxWidth);
      final textSize = textPainter.size;
      final position = textPainter.getPositionForOffset(Offset(
        textSize.width - textPainter.width,
        textSize.height,
      ));
      final endOffset = textPainter.getOffsetBefore(position.offset - 0);
      // if (widget.note.noteTitle.contains('test')) {
      //   print(widget.note.noteTitle);
      //   print(textSize);
      //   print(position);
      //   print(endOffset);
      //   print(textPainter.didExceedMaxLines);
      // }

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
                  visible: widget.note.noteTitle != "",
                  child: SizedBox(
                    child: widget.note.noteTitle.contains(widget.searchText) &&
                            widget.searchText != ''
                        ? buildRichText(
                            widget.note.noteTitle,
                            widget.searchText,
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
                            widget.note.noteTitle,
                            maxLines: 3,
                            softWrap: true,
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
                          widget.note.noteContext,
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
                      : Text(
                          isExpanded
                              ? widget.note.noteContext
                              : widget.note.noteContext.substring(0, endOffset),
                          overflow: TextOverflow.clip,
                          softWrap: true,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                  // textPainter.didExceedMaxLines
                  //     ? RichText(
                  //         overflow: TextOverflow.clip,
                  //         text: TextSpan(
                  //           text: isCollapsed
                  //               ? widget.note.noteContext
                  //               : widget.note.noteContext
                  //                   .substring(0, endOffset),
                  //           style: const TextStyle(
                  //               fontSize: 16,
                  //               color: Colors.black,
                  //               fontFamily: 'LXGWWenKai'),
                  //           children: [
                  //             TextSpan(
                  //               text: isCollapsed ? "\n收起" : "\n展开",
                  //               style: const TextStyle(
                  //                   color:
                  //                       Color.fromARGB(255, 0, 140, 198)),
                  //               recognizer: TapGestureRecognizer()
                  //                 ..onTap = () {
                  //                   setState(() {
                  //                     print(
                  //                         'old :   ${textPainter.didExceedMaxLines}');
                  //                     isCollapsed = !isCollapsed;
                  //                     print(
                  //                         'new :   ${textPainter.didExceedMaxLines}');
                  //                   });
                  //                 },
                  //             ),
                  //           ],
                  //         ),
                  //       )
                  //     : Text(
                  //         widget.note.noteContext,
                  //         overflow: TextOverflow.clip,
                  //         softWrap: true,
                  //         style: const TextStyle(
                  //           fontSize: 16,
                  //         ),
                  //       ),
                ),
                Visibility(
                  visible: textPainter.didExceedMaxLines,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          isExpanded = !isExpanded;
                          setState(() {});
                        },
                        child: Text(
                          isExpanded == false ? "展开" : "收起",
                          style: const TextStyle(color: Colors.black38),
                        ),
                      ),
                    ],
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
                // Visibility(
                //   visible: textPainter.didExceedMaxLines,
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.end,
                //     children: [
                //       GestureDetector(
                //         onTap: () {
                //           isCollapsed = !isCollapsed;

                //           setState(() {});
                //         },
                //         child: Text(
                //           isCollapsed == false ? "展开" : "收起",
                //           style: const TextStyle(color: Colors.black38),
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
      );
    });
  }
}
