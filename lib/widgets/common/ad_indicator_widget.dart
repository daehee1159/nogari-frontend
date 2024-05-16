import 'package:flutter/material.dart';

import '../../views/home.dart';
import '../../models/common/temp_nogari.dart';

class AdIndicatorWidget extends StatelessWidget {
  const AdIndicatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = getIt.get<TempNogari>();

    return ValueListenableBuilder<bool>(
      valueListenable: provider.isWatchingAdNotifier,
      builder: (context, isWatchingAd, child) {
        if (isWatchingAd) {
          // isWatchingAd가 true일 때의 작업 수행
          // WidgetsBinding.instance.addPostFrameCallback((_) 을 하지 않으면 setState() or markNeedsBuild() called during build. 오류 발생함
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pop(context);
          });
          return Container(); // 또는 원하는 다른 위젯 반환
        } else {
          // isWatchingAd가 false일 때의 작업 수행
          return Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    '광고 준비중',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 10,),
                const Center(child: CircularProgressIndicator(color: Color(0xff33D679),)),
              ],
            ),
          );
        }
      },
    );
  }
}
