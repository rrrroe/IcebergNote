import 'package:icebergnote/constants.dart';
import 'package:unicode_emojis/unicode_emojis.dart';
import 'package:flutter/material.dart';
import 'package:icebergnote/extensions/icondata_serialization.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

Future<List<String>> loadAsset(String path) async {
  String manifestContent = await rootBundle.loadString('AssetManifest.json');
  Map<String, dynamic> manifestMap = json.decode(manifestContent);
  List<String> imagePaths = manifestMap.keys
      .where((String key) => key.contains(path) && key.endsWith('.png'))
      .toList();
  return imagePaths;
}

class IconPickerAlertDialog extends StatefulWidget {
  final Function(String) onSubmitted;
  final String oldIcon;

  const IconPickerAlertDialog({
    super.key,
    required this.onSubmitted,
    required this.oldIcon,
  });

  @override
  IconPickerAlertDialogState createState() => IconPickerAlertDialogState();
}

class IconPickerAlertDialogState extends State<IconPickerAlertDialog> {
  late Widget currentIcon;
  late String name;
  String group = '生活';
  List<String> groupList = ['生活', '表情'];
  static const emojis = UnicodeEmojis.allEmojis;
  Emoji? newEmoji;
  final TextEditingController _controller = TextEditingController();
  List<String> lifeIcon = [];

  List<String> filterSelectList = [];
  void _submit() {
    widget.onSubmitted(name);
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    currentIcon = iconDataToWidget(widget.oldIcon, 40, 1);
    lifeIcon = List.generate(
      417,
      (int index) => 'image${index + 1}.png',
    );
    super.initState();
  }

  Wrap buildIconList(String group) {
    if (group == '表情') {
      return Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 0,
        runSpacing: 0,
        children: List.generate(
          emojis.length,
          (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  name = 'Emoji||Common||${emojis[index].emoji}';
                  currentIcon = iconDataToWidget(name, 40, 1);
                });
              },
              child: Text(
                emojis[index].emoji,
                style: const TextStyle(fontSize: 30),
              ),
            );
          },
        ),
      );
    }
    if (group == '生活') {
      return Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 0,
        runSpacing: 0,
        children: List.generate(
          lifeIcon.length,
          (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  name = 'Image||LifeIcon||${lifeIcon[index]}';
                  currentIcon = iconDataToWidget(name, 40, 1);
                });
              },
              child: Image.asset(
                'lib/assets/icon/LifeIcon/${lifeIcon[index]}',
                height: 50,
                width: 50,
              ),
            );
          },
        ),
      );
    }
    return const Wrap();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      insetPadding: const EdgeInsets.all(20),
      actionsPadding: const EdgeInsets.all(10),
      title: Container(
        width: 600,
        height: 50,
        constraints: const BoxConstraints(
          minHeight: 24,
          maxHeight: 81,
        ),
        padding: const EdgeInsets.all(0),
        alignment: Alignment.topCenter,
        child: currentIcon,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              MenuAnchor(
                style: menuAnchorStyle,
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
                      group,
                      style: const TextStyle(
                          color: Color.fromARGB(255, 56, 128, 186)),
                    ),
                  );
                },
                menuChildren: groupList.map((type) {
                  return MenuItemButton(
                    style: menuChildrenButtonStyle,
                    child: Text(type),
                    onPressed: () async {
                      // if (type == '生活') {
                      //   lifeIcon = await loadAsset('lib/assets/icon/LifeIcon/');
                      // }
                      setState(() {
                        group = type;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _controller,
                  autofocus: false,
                  decoration: const InputDecoration(
                      hintText: '搜索', border: InputBorder.none),
                  onChanged: (text) {},
                  onSubmitted: (text) {},
                ),
              )
            ],
          ),
          Flexible(
            child: SingleChildScrollView(
              child: buildIconList(group),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text(
            '取消',
            // style: TextStyle(color: widget.fontColor),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text(
            '确定',
            // style: TextStyle(color: widget.fontColor),
          ),
        ),
      ],
      actionsAlignment: MainAxisAlignment.spaceAround,
    );
  }
}
