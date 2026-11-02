import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class SettingsFeedbackScreen extends StatefulWidget {
  const SettingsFeedbackScreen({super.key});

  @override
  State<SettingsFeedbackScreen> createState() => _SettingsFeedbackScreenState();
}

class _SettingsFeedbackScreenState extends State<SettingsFeedbackScreen> {
  final _email = TextEditingController();
  final _name = TextEditingController();
  final _issue = TextEditingController();
  final List<XFile> _attachments = [];
  bool _includeDiagnostics = true;
  bool _sending = false;

  @override
  void dispose() {
    _email.dispose();
    _name.dispose();
    _issue.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          leadingWidth: 86,
          leading: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back', style: TextStyle(fontSize: 16)),
          ),
          title: const Text('Feedback', style: TextStyle(fontWeight: FontWeight.w700)),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: [
                  _label('Email'),
                  _field(_email, hint: 'Optional', keyboardType: TextInputType.emailAddress),
                  _label('Name'),
                  _field(_name, hint: 'Optional'),
                  _label('Issue'),
                  _field(_issue, hint: 'Describe the issue in detail.', maxLines: 7),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _includeDiagnostics,
                    onChanged: (value) => setState(() => _includeDiagnostics = value ?? false),
                    title: const Text('Send diagnostic data to help resolve issues'),
                    subtitle: const Text('Only app version and device platform are included.'),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const SizedBox(height: 8),
                  Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
                    const Text('Attach files to illustrate the issue. '),
                    TextButton.icon(
                      onPressed: _pickAttachments,
                      icon: const Icon(Icons.attach_file_rounded, size: 19),
                      label: Text(_attachments.isEmpty ? 'Attach files' : 'Add more'),
                    ),
                  ]),
                  if (_attachments.isNotEmpty)
                    Wrap(spacing: 8, runSpacing: 4, children: _attachments.map((file) => InputChip(
                      label: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 190),
                        child: Text(file.name, overflow: TextOverflow.ellipsis),
                      ),
                      onDeleted: () => setState(() => _attachments.remove(file)),
                    )).toList()),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _sending || _issue.text.trim().isEmpty ? null : _send,
                  child: _sending ? const CircularProgressIndicator() : const Text('Send'),
                ),
              ),
            ),
          ]),
        ),
      );

  Widget _label(String label) => Padding(
        padding: const EdgeInsets.only(top: 13, bottom: 8),
        child: Text(label, style: const TextStyle(color: Color(0xFF777777), fontSize: 15)),
      );

  Widget _field(TextEditingController controller, {required String hint, int maxLines = 1, TextInputType? keyboardType}) => TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          contentPadding: const EdgeInsets.all(14),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFD8D8D8))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2F80ED))),
        ),
      );

  Future<void> _pickAttachments() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true, withData: false);
    if (!mounted || result == null) return;
    final picked = result.files.where((file) => file.path != null).map((file) => XFile(file.path!, name: file.name));
    setState(() {
      for (final file in picked) {
        if (!_attachments.any((existing) => existing.path == file.path)) _attachments.add(file);
      }
    });
  }

  Future<void> _send() async {
    setState(() => _sending = true);
    final diagnostics = _includeDiagnostics ? '\n\nApp: Paper PDF 1.0\nPlatform: ${Platform.operatingSystem}' : '';
    final message = 'Feedback${_name.text.trim().isEmpty ? '' : ' from ${_name.text.trim()}'}'
        '${_email.text.trim().isEmpty ? '' : '\nEmail: ${_email.text.trim()}'}\n\n${_issue.text.trim()}$diagnostics';
    try {
      await SharePlus.instance.share(ShareParams(
        subject: 'Paper PDF feedback',
        text: message,
        files: _attachments.isEmpty ? null : _attachments,
      ));
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open the share sheet: $error')));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }
}
