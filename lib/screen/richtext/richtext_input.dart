import 'dart:async';
import 'dart:convert';
import 'dart:io' as io show Directory, File;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:icebergnote/class/notes.dart';
import 'package:icebergnote/main.dart';
import 'package:icebergnote/postgresql/sync.dart';
import 'package:icebergnote/theme.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:realm/realm.dart';

class RichTextPage extends StatefulWidget {
  const RichTextPage(
      {super.key, required this.note, required this.onPageClosed});
  final Notes note;
  final VoidCallback onPageClosed;
  @override
  State<RichTextPage> createState() => _RichTextPageState();
}

class _RichTextPageState extends State<RichTextPage> {
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
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();
  TextEditingController titleController = TextEditingController();
  Timer? _debounce;
  @override
  void initState() {
    super.initState();
    // Load document
    titleController.text = widget.note.noteTitle;
    if (widget.note.noteContext != '') {
      _controller.document =
          Document.fromJson(jsonDecode(widget.note.noteContext));
    } else {
      _controller.document = Document.fromJson([
        {"insert": "\n"}
      ]);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _editorScrollController.dispose();
    _editorFocusNode.dispose();
    titleController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Quill Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.output),
            tooltip: 'Print Delta JSON to log',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content:
                      Text('The JSON Delta has been printed to the console.')));
              debugPrint(jsonEncode(_controller.document.toDelta().toJson()));
            },
          ),
        ],
      ),
      body: SafeArea(
          child: Stack(
        children: [
          Column(
            children: [
              TextField(
                textAlign: TextAlign.center,
                controller: titleController,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
                minLines: 1,
                maxLines: 2,
                decoration: const InputDecoration(
                    labelText: "标题",
                    labelStyle: TextStyle(
                      color: Colors.grey,
                    )
                    // border: OutlineInputBorder(),
                    // focusedBorder:
                    //     OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                    // enabledBorder: OutlineInputBorder(
                    //     borderSide: BorderSide(color: Colors.blue)),
                    ),
                onChanged: _onTitleChanged,
              ),
              QuillSimpleToolbar(
                controller: _controller,
                config: QuillSimpleToolbarConfig(
                  toolbarIconAlignment: WrapAlignment.start,
                  multiRowsDisplay: Platform.isWindows ||
                      Platform.isMacOS ||
                      Platform.isLinux,
                  showDividers: false,
                  showFontFamily: false,
                  showFontSize: false,
                  showBoldButton: false,
                  showItalicButton: false,
                  showSmallButton: false,
                  showUnderLineButton: false,
                  showLineHeightButton: false,
                  showStrikeThrough: false,
                  showInlineCode: false,
                  showColorButton: false,
                  showBackgroundColorButton: false,
                  showClearFormat: false,
                  showAlignmentButtons: false,
                  showLeftAlignment: true,
                  showCenterAlignment: true,
                  showRightAlignment: true,
                  showJustifyAlignment: true,
                  showHeaderStyle: true,
                  showListNumbers: false,
                  showListBullets: false,
                  showListCheck: true,
                  showCodeBlock: true,
                  showQuote: true,
                  showIndent: true,
                  showLink: true,
                  showUndo: true,
                  showRedo: true,
                  showDirection: false,
                  showSearchButton: false,
                  showSubscript: false,
                  showSuperscript: false,
                  showClipboardCut: false,
                  showClipboardCopy: false,
                  showClipboardPaste: false,

                  linkStyleType: LinkStyleType.original,
                  headerStyleType: HeaderStyleType.original,
                  decoration: null,
                  embedButtons: FlutterQuillEmbeds.toolbarButtons(
                      imageButtonOptions: QuillToolbarImageButtonOptions(
                          imageButtonConfig: QuillToolbarImageConfig(
                    onImageInsertCallback: (imageUrl, quillController) async {
                      String newUrl = await _onImagePickCallback(
                          File(imageUrl), appDocumentDir!);

                      quillController
                        ..skipRequestKeyboard = true
                        ..insertImageBlock(imageSource: newUrl);
                    },
                  ))),
                  linkDialogAction: null,
                  dialogTheme: null,
                  iconTheme: null,
                  axis: Axis.horizontal,
                  color: null,
                  sectionDividerColor: null,
                  sectionDividerSpace: null,
                  toolbarSize: null,
                  toolbarRunSpacing: 0,
                  // customButtons: [
                  //   QuillToolbarCustomButtonOptions(
                  //     icon: const Icon(Icons.add_alarm_rounded),
                  //     onPressed: () {
                  //       _controller.document.insert(
                  //         _controller.selection.extentOffset,
                  //         TimeStampEmbed(
                  //           DateTime.now().toString(),
                  //         ),
                  //       );

                  //       _controller.updateSelection(
                  //         TextSelection.collapsed(
                  //           offset: _controller.selection.extentOffset + 1,
                  //         ),
                  //         ChangeSource.local,
                  //       );
                  //     },
                  //   ),
                  // ],
                  buttonOptions: QuillSimpleToolbarButtonOptions(
                    base: QuillToolbarBaseButtonOptions(
                      iconSize: 13,
                      afterButtonPressed: () {
                        final isDesktop = {
                          TargetPlatform.linux,
                          TargetPlatform.windows,
                          TargetPlatform.macOS
                        }.contains(defaultTargetPlatform);
                        if (isDesktop) {
                          _editorFocusNode.requestFocus();
                        }
                      },
                    ),
                    linkStyle: QuillToolbarLinkStyleButtonOptions(
                      validateLink: (link) {
                        // Treats all links as valid. When launching the URL,
                        // `https://` is prefixed if the link is incomplete (e.g., `google.com` → `https://google.com`)
                        // however this happens only within the editor.
                        return true;
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                child: QuillEditor(
                  focusNode: _editorFocusNode,
                  scrollController: _editorScrollController,
                  controller: _controller,
                  config: QuillEditorConfig(
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
                            fontSize: 32,
                            wordSpacing: 4,
                            textBaseline: TextBaseline.ideographic,
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
                            fontSize: 26,
                            wordSpacing: 4,
                            textBaseline: TextBaseline.ideographic,
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
                            fontSize: 20,
                            wordSpacing: 4,
                            textBaseline: TextBaseline.ideographic,
                            color: fontColorPurple,
                            fontFamily: 'LXGWWenKai',
                            fontWeight: FontWeight.w600),
                        const HorizontalSpacing(0, 0), // 段落间距
                        const VerticalSpacing(10, 0),
                        const VerticalSpacing(0, 0),
                        null,
                      ),
                    ),
                    placeholder: '开始创作',
                    padding: const EdgeInsets.all(16),
                    embedBuilders: [
                      ...FlutterQuillEmbeds.editorBuilders(
                        imageEmbedConfig: QuillEditorImageEmbedConfig(
                          imageProviderBuilder: (context, imageUrl) {
                            // https://pub.dev/packages/flutter_quill_extensions#-image-assets
                            if (imageUrl.startsWith('icebergnote/')) {
                              return FileImage(
                                  File('${appDocumentDir!.path}/$imageUrl'));
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
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 40,
              decoration:
                  BoxDecoration(color: Theme.of(context).secondaryHeaderColor),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('取消'),
                  ),
                  TextButton(
                    onPressed: () async {
                      save();
                      syncNoteToRemote(widget.note);
                      Navigator.pop(context);
                      widget.onPageClosed();
                    },
                    child: const Text('保存'),
                  ),
                ],
              ),
            ),
          ),
        ],
      )),
    );
  }

  save() {
    realm.write(() {
      widget.note.noteContext =
          jsonEncode(_controller.document.toDelta().toJson());
      widget.note.noteTitle = titleController.text;
      widget.note.noteUpdateDate = DateTime.now().toUtc();
    });
  }

  void _onTitleChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () async {
      realm.write(() {
        widget.note.noteTitle = value;
        widget.note.noteUpdateDate = DateTime.now().toUtc();
      });
    });
  }

  void _onContextChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () async {
      realm.write(() {
        widget.note.noteContext =
            jsonEncode(_controller.document.toDelta().toJson());
        widget.note.noteUpdateDate = DateTime.now().toUtc();
      });
    });
  }
}

Future<String> _onImagePickCallback(
    io.File pickedImage, Directory appDocumentDir) async {
  userLocalInfo = await SharedPreferences.getInstance();
  if (userLocalInfo != null) {
    userID = userLocalInfo!.getString('userID');
  }
  // 1. 获取应用的本地文档目录
  final filename = '${Uuid.v4()}_${pickedImage.uri.pathSegments.last}';
  final relativePath = 'icebergnote/user${userID ?? 'tmp'}/images/';

  final fullPath = '${appDocumentDir.path}/$relativePath$filename';

  // 2. 确保目标目录存在
  final directory = Directory('${appDocumentDir.path}/$relativePath');
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }

  // 3. 复制图片到目标路径
  final file = File(pickedImage.path);
  await file.copy(fullPath);

  // 4. 返回相对路径
  return relativePath + filename;
}

class TimeStampEmbed extends Embeddable {
  const TimeStampEmbed(
    String value,
  ) : super(timeStampType, value);

  static const String timeStampType = 'timeStamp';

  static TimeStampEmbed fromDocument(Document document) =>
      TimeStampEmbed(jsonEncode(document.toDelta().toJson()));

  Document get document => Document.fromJson(jsonDecode(data));
}

class TimeStampEmbedBuilder extends EmbedBuilder {
  @override
  String get key => 'timeStamp';

  @override
  String toPlainText(Embed node) {
    return node.value.data;
  }

  @override
  Widget build(
    BuildContext context,
    EmbedContext embedContext,
  ) {
    return Row(
      children: [
        const Icon(Icons.access_time_rounded),
        Text(embedContext.node.value.data as String),
      ],
    );
  }
}
