import 'package:flutter/material.dart';

class InputAlertDialog extends StatefulWidget {
  final Function(String) onSubmitted;

  const InputAlertDialog({super.key, required this.onSubmitted});

  @override
  // ignore: library_private_types_in_public_api
  _InputAlertDialogState createState() => _InputAlertDialogState();
}

class _InputAlertDialogState extends State<InputAlertDialog> {
  late String inputText;
  final TextEditingController _controller = TextEditingController();

  void _submit() {
    final text = _controller.text;
    widget.onSubmitted(text);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('新建'),
      content: TextField(controller: _controller),
      actions: <Widget>[
        TextButton(
          child: const Text('取消'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text('确定'),
        ),
      ],
    );
  }
}
