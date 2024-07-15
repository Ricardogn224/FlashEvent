import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomFormField extends StatelessWidget {
  final String hintText;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String?)? onChange;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? initialValue;

  const CustomFormField({
    Key? key,
    required this.hintText,
    this.inputFormatters,
    this.validator,
    this.onChange,
    this.controller,
    this.focusNode,
    this.initialValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        initialValue: initialValue,
        inputFormatters: inputFormatters,
        validator: validator,
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(hintText: hintText),
        onChanged: (value) {
          if (onChange != null) {
            onChange!(value);
          }
        },
      ),
    );
  }
}
