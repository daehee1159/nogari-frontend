import 'keyboard_buttons.dart';
import 'package:flutter/material.dart';

class KeyboardRows extends StatelessWidget {
  const KeyboardRows({super.key, required this.rowsButtons, required this.onTap});

  final List<String> rowsButtons;
  final CallbackButtonTap onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: buttons(),
    );
  }

  List<Widget> buttons() {
    List<Widget> buttons = [];
    rowsButtons.forEach((String buttonText) {
      buttons.add(
        KeyboardButtons(
          buttons: buttonText,
          onTap: onTap,
        ),
      );
    });
    return buttons;
  }
}
