import 'package:flutter/material.dart';

class EventRow extends StatelessWidget{
  final Widget icon;
  final String text;
  final Function()? onPressed;
  final Color border;

  const EventRow({
    super.key, required this.icon, required this.text, required this.onPressed, required this.border
  });


  @override
  Widget build(BuildContext context) {
    return Container(
              child: FilledButton(
                onPressed: onPressed, child: Text(text)),
            );
  }
}