import 'package:flutter/material.dart';

void showSuccessDialog(
  BuildContext context,
  String title,
  String message,
  VoidCallback onOk,
) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [TextButton(onPressed: onOk, child: const Text("OK"))],
    ),
  );
}
