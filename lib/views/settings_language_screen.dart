import 'package:flutter/material.dart';

class SettingsLanguageScreen extends StatelessWidget {
  const SettingsLanguageScreen({super.key, required this.selected});
  final String selected;

  static const options = <String>['Auto', 'English'];

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Back',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          title: const Text('Language', style: TextStyle(fontWeight: FontWeight.w700)),
          centerTitle: true,
        ),
        body: ListView.builder(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          itemCount: options.length,
          itemBuilder: (context, index) {
            final value = options[index];
            final isSelected = value == selected;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: isSelected ? Theme.of(context).colorScheme.surfaceContainerHighest : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                child: ListTile(
                  title: Text(value, style: const TextStyle(fontSize: 17)),
                  trailing: Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: isSelected ? const Color(0xFF2F80ED) : const Color(0xFFB9BDC3),
                  ),
                  onTap: () => Navigator.pop(context, value),
                ),
              ),
            );
          },
        ),
      );
}
