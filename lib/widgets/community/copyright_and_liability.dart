import 'package:flutter/material.dart';

class CopyrightAndLiability extends StatelessWidget {
  const CopyrightAndLiability({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            '게시물의 저작권과 책임',
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10,),
          Text(
            '1. 커뮤니티 및 리뷰 게시판에 게시한 게시물의 저작권은 게시자 본인에게 있습니다.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 10,),
          Text(
            '2. 작성한 게시물로 인해 발생되는 문제에 대해서는 해당 게시물을 게시한 게시자에게 책임이 있습니다.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 10,),
          Text(
            '3. 작성된 게시물이 타인의 저작권, 프로그램 저작권 등을 침해할 경우 이에 대한 민,형사상의 책임은 글 게시자에게 있습니다. 만일 이를 이유로 회사가 타인으로부터 손해배상청구 등 이의 제기를 받은 경우 해당 게시자는 그로 인해 발생되는 모든 손해를 부담해야 합니다.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

