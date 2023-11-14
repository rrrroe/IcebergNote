import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

String deviceUniqueId = '未知设备';
Future<void> getUniqueId() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) {
    IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
    deviceUniqueId =
        iosDeviceInfo.identifierForVendor ?? '未知设备'; // unique ID on iOS
  }
  if (Platform.isAndroid) {
    AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;

    deviceUniqueId = androidDeviceInfo.id; // unique ID on Android
  }
  if (Platform.isWindows) {
    WindowsDeviceInfo windowsDeviceInfo = await deviceInfo.windowsInfo;

    deviceUniqueId = windowsDeviceInfo.deviceId; // unique ID on Android
  }
  if (Platform.isLinux) {
    LinuxDeviceInfo linuxDeviceInfo = await deviceInfo.linuxInfo;

    deviceUniqueId = linuxDeviceInfo.id; // unique ID on Android
  }
  if (Platform.isAndroid) {
    MacOsDeviceInfo macOsDeviceInfo = await deviceInfo.macOsInfo;

    deviceUniqueId =
        macOsDeviceInfo.systemGUID ?? '未知设备'; // unique ID on Android
  }
}
