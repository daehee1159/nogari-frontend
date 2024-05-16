import 'package:flutter/material.dart';
import 'package:nogari/services/common_service.dart';
import 'package:nogari/views/home.dart';
import 'package:nogari/models/common/temp_nogari.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = getIt.get<TempNogari>();
    if (provider.getIsIntentional) {
      provider.setIsIntentional = false;
      Future<dynamic> result = CommonService().fetchData(context);
      result.then((value) {
        if (value == true) {
          Future.delayed(const Duration(milliseconds: 1500), () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const Home(currentIndex: 0,)));
          });
        } else {
          // fetch data 실패
          // GlobalFunc().setErrorLog("SplashScreen _fetchData Error value = $value");
        }
      });
    }

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                'images/nogari_icon_big.png',
                height: MediaQuery.of(context).size.height * 0.2,
                // color: const Color(0xffFE9BE6),
                fit: BoxFit.contain,
              ),
            ),
            const Center(child: CircularProgressIndicator(color: Color(0xff33D679),)),
          ],
        ),
      ),
    );
  }
}
