// ========== IMPORTS ========== //
// Flutter
import 'package:flutter/material.dart';

// Themes
import '../themes/dark_theme.dart';
import '../themes/light_theme.dart';

class CustomCheckBox extends StatefulWidget {
  @override
  _CustomCheckBoxState createState() => _CustomCheckBoxState();
}

class _CustomCheckBoxState extends State<CustomCheckBox> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isChecked = !isChecked;
        });
      },
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: isChecked ? Colors.blue : Colors.transparent,
          border: Border.all(
            color: isChecked ? Colors.blue : Colors.grey,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: isChecked
            ? const Icon(
                Icons.check,
                color: Colors.white,
                size: 15,
              )
            : null,
      ),
    );
  }
}