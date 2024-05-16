import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {

  final Color color;

  final Color textColor;
  final Icon icon;
  final String title;
  final Widget? rightWidget;
  final VoidCallback callback;
  const ItemCard({super.key, required this.icon, required this.title, required this.color, required this.rightWidget, required this.callback, required this.textColor});

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: callback,
      child: Container(
        height: 60,
        color: color,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.only(left: 10),
                child: icon,
              ),
            ),
            Expanded(
              flex: 10,
              child: Container(
                padding: const EdgeInsets.only(left: 14),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w500, color: textColor)
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.only(right: 24),
                child: rightWidget,
              ),
            )
          ],
        ),
      ),
    );
  }
}
