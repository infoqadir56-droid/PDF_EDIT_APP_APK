import 'package:flutter/material.dart';
import '../models/library_item.dart';
import 'pdf_ai_chat_screen.dart';

class PdfAiScreen extends StatelessWidget {
  const PdfAiScreen({super.key, required this.item, required this.onChatNow});

  final LibraryItem item;
  final VoidCallback onChatNow;

  static Future<void> show(BuildContext context, LibraryItem item) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => PdfAiScreen(
          item: item,
          onChatNow: () {
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => PdfAiChatScreen(item: item)),
            );
          },
        ),
      );

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(22, 22, 22, MediaQuery.viewInsetsOf(context).bottom + 22),
          decoration: const BoxDecoration(
            color: Color(0xFFFAFAFA),
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(color: const Color(0xFFEF6660), borderRadius: BorderRadius.circular(13)),
                child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 27),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('ChatBot - Powered by ChatGPT', style: TextStyle(color: Colors.black54, fontSize: 13)),
                  SizedBox(height: 3),
                  Text('Chat, Learn, Earn.', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                ]),
              ),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, color: Colors.black54)),
            ]),
            const SizedBox(height: 22),
            Text(
              'With Paper, your documents are becoming intelligent. Quickly extract information from ${item.name}. Try asking your file a question.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 17, height: 1.35),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: onChatNow,
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF1976E8), shape: const StadiumBorder()),
                child: const Text('Chat Now', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
          ]),
        ),
      );
}
