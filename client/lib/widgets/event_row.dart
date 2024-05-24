import 'package:flutter/material.dart';

class EventRow extends StatelessWidget {
  final Widget icon;
  final String text;
  final Function()? onPressed;
  final Color border;
  final Color backgroundColor;
  final double height; // New property for height
  final double maxWidth; // New property for maximum width of the text
  final double fontSize; // New property for font size

  const EventRow({
    Key? key,
    required this.icon,
    required this.text,
    required this.onPressed,
    required this.border,
    this.backgroundColor = Colors.yellow,
    this.height = 80.0, // Default height is 50.0
    this.maxWidth = 230.0, // Default maximum width
    this.fontSize = 18.0, // Default font size
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      height: height, // Set the height of the container
      child: FilledButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Text(
                text,
                overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis
                style: TextStyle(fontSize: fontSize), // Set the font size
              ),
            ),
            icon,
          ],
        ),
      ),
    );
  }
}
