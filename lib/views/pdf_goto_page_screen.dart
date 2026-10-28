import 'package:flutter/material.dart';

class PdfGoToPageScreen {
  static Future<int?> show(BuildContext context, {required int currentPage, required int pageCount}) async {
    final controller = TextEditingController(text: '$currentPage');
    return showDialog<int>(context: context, builder: (dialogContext) => AlertDialog(
      title: const Text('Go to Page'),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Enter Page Number (1-$pageCount)', style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 14),
        TextField(controller: controller, autofocus: true, keyboardType: TextInputType.number, decoration: const InputDecoration(border: OutlineInputBorder(), suffixText: 'page')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
        FilledButton(onPressed: () { final value = int.tryParse(controller.text); if (value != null && value >= 1 && value <= pageCount) Navigator.pop(dialogContext, value); }, child: const Text('OK')),
      ],
    ));
  }
}
