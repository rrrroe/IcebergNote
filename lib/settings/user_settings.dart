import 'dart:convert';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:icebergnote/class/anniversary_class.dart';
import 'package:icebergnote/constants.dart';
import 'package:icebergnote/main.dart';
import 'package:icebergnote/class/notes.dart';
import 'package:icebergnote/postgresql/sync.dart';
import 'package:icebergnote/screen/card/anniversary_card.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:icebergnote/screen/widget/input_alert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slide_switcher/slide_switcher.dart';

// ignore: must_be_immutable
class SettingsPage extends StatefulWidget {
  final VoidCallback onPageClosed;
  final Notes note;
  final int mod;

  const SettingsPage({
    super.key,
    required this.onPageClosed,
    required this.note,
    required this.mod,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SharedPreferences userLocalInfo;
  TextEditingController settingSavePathWindows = TextEditingController();
  TextEditingController settingSavePathAndroid = TextEditingController();
  @override
  Future<void> initState() async {
    userLocalInfo = await SharedPreferences.getInstance();
    settingSavePathWindows.text =
        userLocalInfo.getString('settingSavePathWindows') ?? '';
    settingSavePathAndroid.text =
        userLocalInfo.getString('settingSavePathAndroid') ?? '';

    super.initState();
  }

  @override
  void dispose() {
    settingSavePathWindows.dispose();
    settingSavePathAndroid.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 25, vertical: 0),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              '截图保存路径',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 10, height: 28),
                            Expanded(
                              child: TextField(
                                textAlign: TextAlign.right,
                                controller: settingSavePathWindows,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                minLines: 1,
                                maxLines: 1,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 0),
                                  isDense: true,
                                ),
                                onChanged: (value) async {},
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 40,
              )
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
      ),
    );
  }
}
