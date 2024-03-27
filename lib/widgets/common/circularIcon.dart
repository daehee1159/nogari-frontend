import 'package:flutter/material.dart';

class CircularIcon extends StatelessWidget {
  final IconData icon;
  final String text;
  const CircularIcon({required this.icon, required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.12,
          height: MediaQuery.of(context).size.height * 0.06,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              )
            ],
            color: const Color(0xff33D679),
          ),
          child: Center(
            child: Icon(
              icon,
              color: Colors.white,
              size: MediaQuery.of(context).size.height * 0.025,
            ),
          ),
        ),
        const SizedBox(height: 10.0,),
        Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: (text == '준비중') ? Colors.grey : Colors.black,)
          ),
        )
      ],
    );
  }
}
