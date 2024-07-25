import 'package:flutter/material.dart';

void poplog(bool n, String m, BuildContext context) {
  if (n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        width: 90,
        content: Text(
          '$m成功',
          textAlign: TextAlign.start,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        shape: RoundedRectangleBorder(
          // 设置形状
          borderRadius: BorderRadius.circular(20.0),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        elevation: 8.0,
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        width: 90,
        content: Text(
          '$m失败',
          textAlign: TextAlign.start,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onError,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        shape: RoundedRectangleBorder(
          // 设置形状
          borderRadius: BorderRadius.circular(20.0),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        elevation: 8.0,
      ),
    );
  }
}
