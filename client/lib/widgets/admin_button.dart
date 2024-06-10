import 'package:flutter/material.dart';

class AdminButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const AdminButton({Key? key, required this.title, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,  // Set the width of the button
      height: 80,  // Set the height of the button
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(title),
      ),
    );
  }
}
