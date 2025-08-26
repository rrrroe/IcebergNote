import 'dart:async';
import 'dart:convert';
import 'dart:io' as io show Directory, File;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:icebergnote/class/notes.dart';
import 'package:icebergnote/main.dart';
import 'package:icebergnote/postgresql/sync.dart';
import 'package:icebergnote/screen/richtext/quill_delta_sample.dart';
import 'package:path/path.dart' as path;

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
          // stored in the Quill Delta JSON (the document).
          final newFileName =
              'image-file-${DateTime.now().toIso8601String()}.png';
          final newPath = path.join(
            io.Directory.systemTemp.path,
            newFileName,
          );
          final file = await io.File(
            newPath,
          ).writeAsBytes(imageBytes, flush: true);
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
        title: Text('Flutter Quill Example'),
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
                  embedButtons: FlutterQuillEmbeds.toolbarButtons(),
                  showClipboardPaste: true,
                  customButtons: [
                    QuillToolbarCustomButtonOptions(
                      icon: const Icon(Icons.add_alarm_rounded),
                      onPressed: () {
                        _controller.document.insert(
                          _controller.selection.extentOffset,
                          TimeStampEmbed(
                            DateTime.now().toString(),
                          ),
                        );

                        _controller.updateSelection(
                          TextSelection.collapsed(
                            offset: _controller.selection.extentOffset + 1,
                          ),
                          ChangeSource.local,
                        );
                      },
                    ),
                  ],
                  buttonOptions: QuillSimpleToolbarButtonOptions(
                    base: QuillToolbarBaseButtonOptions(
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
                    placeholder: 'Start writing your notes...',
                    padding: const EdgeInsets.all(16),
                    embedBuilders: [
                      ...FlutterQuillEmbeds.editorBuilders(
                        imageEmbedConfig: QuillEditorImageEmbedConfig(
                          imageProviderBuilder: (context, imageUrl) {
                            // https://pub.dev/packages/flutter_quill_extensions#-image-assets
                            if (imageUrl.startsWith('assets/')) {
                              return AssetImage(imageUrl);
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

class RichTextStorage {
  // 将 QuillController 的内容转换为 JSON 字符串
  static String convertToStorageFormat(QuillController controller) {
    final delta = controller.document.toDelta();
    return jsonEncode(delta.toJson());
  }

  // 从 JSON 字符串恢复 QuillController
  static QuillController restoreFromStorageFormat(String contentJson) {
    try {
      final json = jsonDecode(contentJson) as List;
      final delta = Delta.fromJson(json);
      return QuillController(
        document: Document.fromDelta(delta),
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (e) {
      // 如果解析失败，返回一个空的控制器
      return QuillController.basic();
    }
  }
}
