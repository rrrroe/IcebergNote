import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';

void showToast(BuildContext context, String msg, String msg2, int level) {
  if (level == 0) {
    CherryToast(
            iconWidget: const Icon(
              Icons.error,
              color: Colors.red,
            ),
            iconColor: Colors.red,
            themeColor: Colors.grey,
            description: Text(msg, style: const TextStyle(color: Colors.red)),
            toastPosition: Position.bottom,
            animationType: AnimationType.fromBottom,
            action: Text(msg2, style: const TextStyle(color: Colors.black)),
            animationDuration: const Duration(milliseconds: 1000),
            autoDismiss: true)
        .show(context);
  } else if (level == 1) {
    CherryToast(
            iconWidget: const Icon(
              Icons.info,
              color: Colors.blue,
            ),
            iconColor: Colors.blue,
            themeColor: Colors.grey,
            description: Text(msg, style: const TextStyle(color: Colors.blue)),
            toastPosition: Position.bottom,
            animationType: AnimationType.fromBottom,
            action: Text(msg2, style: const TextStyle(color: Colors.black)),
            animationDuration: const Duration(milliseconds: 1000),
            autoDismiss: true)
        .show(context);
  } else if (level == 2) {
    CherryToast(
            iconWidget: const Icon(
              Icons.check_circle,
              color: Colors.green,
            ),
            iconColor: Colors.green,
            themeColor: Colors.grey,
            description: Text(msg, style: const TextStyle(color: Colors.green)),
            toastPosition: Position.bottom,
            animationType: AnimationType.fromBottom,
            action: Text(msg2, style: const TextStyle(color: Colors.black)),
            animationDuration: const Duration(milliseconds: 1000),
            autoDismiss: true)
        .show(context);
  }
}
