import 'package:flutter/material.dart';
import '../models/library_item.dart';

class PdfAiChatScreen extends StatefulWidget {
  const PdfAiChatScreen({super.key, required this.item});

  final LibraryItem item;

  @override
  State<PdfAiChatScreen> createState() => _PdfAiChatScreenState();
}

class _PdfAiChatScreenState extends State<PdfAiChatScreen> {
  final _message = TextEditingController();

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        appBar: AppBar(
          title: const Text('Chat with PDF'),
          leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
          backgroundColor: Colors.white,
        ),
        body: SafeArea(
          child: Column(children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Text(
                    'Ask a question about ${widget.item.name}. Connect an AI service to receive document answers.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
              child: TextField(
                controller: _message,
                decoration: InputDecoration(
                  hintText: 'Ask about this PDF',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                  suffixIcon: IconButton(onPressed: () {}, icon: const Icon(Icons.send_rounded, color: Color(0xFF2F80ED))),
                ),
              ),
            ),
          ]),
        ),
      );
}
