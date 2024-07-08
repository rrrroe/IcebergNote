import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebergnote/class/notes.dart';
import 'package:icebergnote/main.dart';
import 'package:icebergnote/postgresql/sync.dart';
import 'package:image/image.dart' as img;
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';

Future<Uint8List> onScreenshot(GlobalKey key) async {
  RenderRepaintBoundary boundary =
      key.currentContext!.findRenderObject() as RenderRepaintBoundary;
  ui.Image image = await boundary.toImage(pixelRatio: 2);
  ByteData? byteData = await (image.toByteData(format: ui.ImageByteFormat.png));
  Uint8List pngBytes = byteData!.buffer.asUint8List();
  return pngBytes;
}

class ImagePopup extends StatefulWidget {
  final Uint8List pngBytes;
  final Color mainColor;

  const ImagePopup(
      {super.key, required this.pngBytes, required this.mainColor});

  @override
  State<ImagePopup> createState() => _ImagePopupState();
}

class _ImagePopupState extends State<ImagePopup> {
  late SharedPreferences userLocalInfo;
  GlobalKey aLLRepaintWidgetKey = GlobalKey();
  Uint8List? allPngBytes;
  final Widget svg = SvgPicture.asset(
    'lib/assets/image/icebergnote_download.svg',
    width: 50,
    height: 50,
    semanticsLabel: 'Acme Logo',
    placeholderBuilder: (BuildContext context) => Container(
        padding: const EdgeInsets.all(30.0),
        child: const CircularProgressIndicator()),
    colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
  );
  DateTime? now, old;
  int noteSum = 0;
  int days = 0;
  @override
  void initState() {
    now = DateTime.now();
    old = DateTime.tryParse(userCreatDate ?? '');
    if (old != null) days = now!.difference(old!).inDays + 1;
    var tmp = realm.all<Notes>();
    noteSum = tmp.length;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: RepaintBoundary(
                key: aLLRepaintWidgetKey,
                child: Column(
                  children: [
                    Image.memory(widget.pngBytes),
                    Container(height: 6, color: Colors.white),
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(width: 11),
                          svg,
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName ?? '',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                userID == null ? '' : 'No.$userID',
                                style: const TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                          Expanded(child: Container()),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '$noteSum NOTES',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                '$days DAYS',
                                style: const TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                    ),
                    Container(height: 16, color: Colors.white),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  IconButton.filledTonal(
                    onPressed: () async {
                      // final dir = Directory('export');
                      // dir.create();
                      await Future.delayed(const Duration(milliseconds: 1000));
                      Uint8List pngBytesAll =
                          await onScreenshot(aLLRepaintWidgetKey);
                      String tmp =
                          DateTime.now().toString().replaceAll(':', '');
                      await (img.Command()
                            // Decode the PNG image file
                            ..decodePng(pngBytesAll)
                            // Save the resized image to a PNG image file
                            ..writeToFile('export/export_$tmp.png'))
                          // executeThread will run the commands in an Isolate thread
                          .executeThread();
                      Get.snackbar(
                        '恭喜',
                        '导出已完成',
                        duration: const Duration(seconds: 1),
                        backgroundColor: const Color.fromARGB(60, 0, 140, 198),
                      );
                    },
                    style: ButtonStyle(
                        foregroundColor: WidgetStateProperty.all(Colors.white),
                        backgroundColor: WidgetStateProperty.all(
                            const Color.fromARGB(0, 255, 255, 255))),
                    icon: const Icon(
                      Icons.download,
                      color: Colors.grey,
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: () async {
                      Get.back();
                    },
                    style: ButtonStyle(
                        foregroundColor: WidgetStateProperty.all(Colors.white),
                        backgroundColor: WidgetStateProperty.all(
                            const Color.fromARGB(0, 255, 255, 255))),
                    icon: const Icon(
                      Icons.cancel_rounded,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
