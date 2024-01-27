import 'package:flutter/material.dart';

class CustomConfirmDialog extends StatefulWidget {
  final String message;

  const CustomConfirmDialog(this.message, {super.key});

  @override
  State<CustomConfirmDialog> createState() => _CustomConfirmDialogState();
}

class _CustomConfirmDialogState extends State<CustomConfirmDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(10.0),
        width: 300.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '확 인',
              style: TextStyle(
                color: Colors.orangeAccent,
                fontSize: 30.0,
              ),
            ),
            const SizedBox(
              height: 15.0,
            ),
            Text(
              widget.message,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 20.0,
              ),
            ),
            const SizedBox(
              height: 15.0,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
