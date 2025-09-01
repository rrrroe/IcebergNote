import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:icebergnote/class/notes.dart';
import 'package:icebergnote/main.dart';
import 'package:icebergnote/screen/input/input_screen.dart';
import 'package:icebergnote/screen/richtext/richtext_input.dart';
import 'package:icebergnote/screen/search_screen.dart';
import 'package:icebergnote/theme.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;
import '../noteslist_screen.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

class RichtextCard extends StatefulWidget {
  const RichtextCard(
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
  State<RichtextCard> createState() => RichtextCardState();
}

class RichtextCardState extends State<RichtextCard> {
  bool isExpanded = false;
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load document
    if (widget.note.noteContext != '') {
      _controller.document =
          Document.fromJson(jsonDecode(widget.note.noteContext));
    } else {
      _controller.document = Document.fromJson([
        {"insert": "\n"}
      ]);
    }
  }

  final QuillController _controller = () {
    return QuillController.basic(
        config: QuillControllerConfig(
      clipboardConfig: QuillClipboardConfig(
        enableExternalRichPaste: true,
        onImagePaste: (imageBytes) async {
          if (kIsWeb) {
            // Dart IO is unsupported on the web.
            return null;
          }
          // Save the image somewhere and return the image URL that will be
          final appDir = await getApplicationDocumentsDirectory();
          final imagesDir = io.Directory('${appDir.path}/note_images');
          // 创建图片目录（如果不存在）
          if (!await imagesDir.exists()) {
            await imagesDir.create(recursive: true);
          }
          final newFileName =
              'image-${DateTime.now().millisecondsSinceEpoch}.png';
          final newPath = path.join(imagesDir.path, newFileName);

          // 写入文件到应用目录
          final file =
              await io.File(newPath).writeAsBytes(imageBytes, flush: true);
          // stored in the Quill Delta JSON (the document).
          // final newFileName =
          //     'image-file-${DateTime.now().toIso8601String()}.png';
          // final newPath = path.join(
          //   io.Directory.systemTemp.path,
          //   newFileName,
          // );
          // final file = await io.File(
          //   newPath,
          // ).writeAsBytes(imageBytes, flush: true);
          return file.path;
        },
      ),
    ));
  }();

  void onLongPress() {
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
  }

  void onTap() {
    if (widget.note.noteType == '.图文') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RichTextPage(
            onPageClosed: () {
              widget.refreshList();
            },
            note: widget.note,
          ),
        ),
      );
    } else {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    _controller.readOnly = true;
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
        onTap: onTap,
        onLongPress: onLongPress,
        child: Card(
          margin: const EdgeInsets.fromLTRB(15, 0, 15, 10),
          elevation: 0,
          shadowColor: Colors.grey,
          color: const Color.fromARGB(255, 229, 240, 251),
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
                      : QuillEditor(
                          focusNode: _editorFocusNode,
                          scrollController: _editorScrollController,
                          controller: _controller,
                          config: QuillEditorConfig(
                            autoFocus: false,
                            scrollable: false,
                            showCursor: false,
                            readOnlyMouseCursor: SystemMouseCursors.basic,
                            onTapUp: (a, b) {
                              onTap();
                              return true;
                            },
                            onSingleLongTapEnd: (a, b) {
                              onLongPress();
                              return true;
                            },
                            enableSelectionToolbar: false,
                            customStyles: DefaultStyles(
                              paragraph: const DefaultTextBlockStyle(
                                TextStyle(
                                    fontSize: 18,
                                    wordSpacing: 4,
                                    textBaseline: TextBaseline.ideographic,
                                    color: Colors.black,
                                    fontFamily: 'LXGWWenKai'),
                                HorizontalSpacing(0, 0), // 段落间距
                                VerticalSpacing(10, 0),
                                VerticalSpacing(0, 0),
                                null,
                              ),
                              h1: DefaultTextBlockStyle(
                                TextStyle(
                                    fontSize: 18,
                                    wordSpacing: 4,
                                    textBaseline: TextBaseline.ideographic,
                                    decoration: TextDecoration.underline,
                                    color: fontColorBule,
                                    fontFamily: 'LXGWWenKai',
                                    fontWeight: FontWeight.w600),
                                const HorizontalSpacing(0, 0), // 段落间距
                                const VerticalSpacing(10, 0),
                                const VerticalSpacing(0, 0),
                                null,
                              ),
                              h2: DefaultTextBlockStyle(
                                TextStyle(
                                    fontSize: 18,
                                    wordSpacing: 4,
                                    textBaseline: TextBaseline.ideographic,
                                    decoration: TextDecoration.underline,
                                    color: fontColorGreen,
                                    fontFamily: 'LXGWWenKai',
                                    fontWeight: FontWeight.w600),
                                const HorizontalSpacing(0, 0), // 段落间距
                                const VerticalSpacing(10, 0),
                                const VerticalSpacing(0, 0),
                                null,
                              ),
                              h3: DefaultTextBlockStyle(
                                TextStyle(
                                    fontSize: 18,
                                    wordSpacing: 4,
                                    textBaseline: TextBaseline.ideographic,
                                    decoration: TextDecoration.underline,
                                    color: fontColorPurple,
                                    fontFamily: 'LXGWWenKai',
                                    fontWeight: FontWeight.w600),
                                const HorizontalSpacing(0, 0), // 段落间距
                                const VerticalSpacing(10, 0),
                                const VerticalSpacing(0, 0),
                                null,
                              ),
                            ),
                            placeholder: '',
                            padding: const EdgeInsets.all(0),
                            embedBuilders: [
                              ...FlutterQuillEmbeds.editorBuilders(
                                imageEmbedConfig: QuillEditorImageEmbedConfig(
                                  onImageClicked: (a) {},
                                  imageProviderBuilder: (context, imageUrl) {
                                    // https://pub.dev/packages/flutter_quill_extensions#-image-assets
                                    if (imageUrl.startsWith('icebergnote/')) {
                                      return FileImage(io.File(
                                          '${appDocumentDir!.path}/$imageUrl'));
                                    }
                                    return null;
                                  },
                                ),
                                videoEmbedConfig: QuillEditorVideoEmbedConfig(
                                  customVideoBuilder: (videoUrl, readOnly) {
                                    // To load YouTube videos https://github.com/singerdmx/flutter-quill/releases/tag/v10.8.0
                                    return null;
                                  },
                                ),
                              ),
                              TimeStampEmbedBuilder(),
                            ],
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
              ],
            ),
          ),
        ),
      );
    });
  }
}
