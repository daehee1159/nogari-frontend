import 'package:flutter/material.dart';

class DeleteBoard extends StatelessWidget {
  const DeleteBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Text(
              '게시물 삭제 기준',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10,),
          Text(
            '1. 타인에게 수치심, 혐오감, 불쾌감을 일으키는 게시물',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 10,),
          Text(
            '2. 타인을 협박, 위협하는 게시물',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 10,),
          Text(
            '3. 지속적인 분란을 야기하는 게시물',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 10,),
          Text(
            '4. 홍보성 타 사이트 링크 포함 및 광고 게시물',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 10,),
          Text(
            '5. 저작권 침해 게시물',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 10,),
          Text(
            '6. 음란성 게시물',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 10,),
          Text(
            '7. 의미 없는 내용의 도배성 게시물',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 10,),
          Text(
            '8. 타인을 사칭하여 명예를 훼손하시는 게시물, 타인의 사진 및 개인 정보(이름,주민번호, 연락처 등)를 무단으로 배포하는 게시물',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
