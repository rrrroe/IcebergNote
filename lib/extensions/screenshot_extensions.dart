// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebergnote/class/notes.dart';
import 'package:icebergnote/extensions/toast.dart';
import 'package:icebergnote/main.dart';
import 'package:icebergnote/postgresql/sync.dart';
import 'package:image/image.dart' as img;
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:external_path/external_path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:share_plus/share_plus.dart';

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
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Image.memory(widget.pngBytes),
                      Container(height: 6, color: Colors.white),
                      Container(
                        color: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(width: 20),
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
                            const SizedBox(width: 25),
                          ],
                        ),
                      ),
                      Container(height: 16, color: Colors.white),
                    ],
                  ),
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
                      var status =
                          await Permission.manageExternalStorage.status;
                      if (!status.isProvisional) {
                        // 1. 直接请求权限（跳过初始状态检查）
                        final status =
                            await Permission.manageExternalStorage.request();

                        // 2. 精简状态判断逻辑
                        if (status.isGranted) {
                          // 权限已授予 - 执行导出操作
                          try {
                            Uint8List pngBytesAll =
                                await onScreenshot(aLLRepaintWidgetKey);
                            String tmp = DateTime.now()
                                .millisecondsSinceEpoch
                                .toString();
                            String albumPath = 'export/export_$tmp.png' '';
                            // 3. 获取系统相册目录路径
                            if (Platform.isAndroid) {
                              albumPath = await ExternalPath
                                  .getExternalStoragePublicDirectory(
                                      ExternalPath.DIRECTORY_PICTURES);
                            } else if (Platform.isWindows) {
                              Directory winrDocuments =
                                  await getApplicationDocumentsDirectory();

                              // 2. 替换路径中的 "Documents" 为 "Desktop"
                              String desktopPath = winrDocuments.path
                                  .replaceAll("Documents", "Desktop");

                              // 3. 检查桌面路径是否存在
                              if (Directory(desktopPath).existsSync()) {
                                albumPath = desktopPath; // 返回桌面路径
                              } else if (winrDocuments.existsSync()) {
                                albumPath = winrDocuments.path;
                              }
                            }
                            String filePath =
                                '$albumPath/export_${DateTime.now().millisecondsSinceEpoch}.png';
                            File file = File(filePath);
                            // 5. 保存文件到相册目录
                            await file.writeAsBytes(pngBytesAll);
                            // await (img.Command()
                            //       // Decode the PNG image file
                            //       ..decodePng(pngBytesAll)
                            //       // Save the resized image to a PNG image file
                            //       ..writeToFile('export/export_$tmp.png'))
                            //     // executeThread will run the commands in an Isolate thread
                            //     .executeThread();
                            showToast(context, '导出成功', file.path, 2);
                          } catch (e) {
                            showToast(context, '导出失败', e.toString(), 0);
                          }
                        } else if (status.isPermanentlyDenied) {
                          // 关键：用户永久拒绝，需跳转系统设置
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("需要存储权限"),
                              content: const Text("请在系统设置中启用“允许管理所有文件”权限"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text("取消"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // 跳转应用设置页
                                    const AndroidIntent(
                                      action:
                                          'action_application_details_settings',
                                      data: 'package:icebergnote', // 替换为你的包名
                                    ).launch();
                                    Navigator.pop(ctx);
                                  },
                                  child: const Text("去设置"),
                                ),
                              ],
                            ),
                          );
                        } else {
                          // 临时拒绝或其他状态
                          showToast(context, '导出失败', '存储权限被拒绝', 0);
                        }
                      }
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
                  Visibility(
                    visible: false,
                    child: IconButton.filledTonal(
                      onPressed: () async {
                        Uint8List pngBytesAll =
                            await onScreenshot(aLLRepaintWidgetKey);
                        final tempDir =
                            'export/temp_${DateTime.now().millisecondsSinceEpoch}.png';
                        final file = File(tempDir);
                        await file.writeAsBytes(pngBytesAll);

                        await SharePlus.instance.share(ShareParams(
                          text: '来自${userName ?? ''}的分享',
                          files: [XFile(file.path)],
                        ));
                      },
                      style: ButtonStyle(
                          foregroundColor:
                              WidgetStateProperty.all(Colors.white),
                          backgroundColor: WidgetStateProperty.all(
                              const Color.fromARGB(0, 255, 255, 255))),
                      icon: const Icon(
                        Icons.share,
                        color: Colors.grey,
                      ),
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

Future<void> copyImageToClipboard(Uint8List pngBytes) async {
  // 将图片转换为 Base64
  String base64Image = base64Encode(pngBytes);

  // 将 Base64 字符串复制到剪贴板
  await FlutterClipboard.copy(base64Image).then((value) {
    print('Image copied to clipboard as Base64!');
  });
}
