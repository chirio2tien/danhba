import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? hint;
  final Widget? leading;
  final bool multiline;
  const InputField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.hint,
    this.leading,
    this.multiline = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: t.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            )),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: multiline ? 4 : 1,
          decoration: InputDecoration(
            prefixIcon: leading,
            hintText: hint,
          ),
        )
      ],
    );
  }
}