import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nogari/models/global/global_variable.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  late BannerAd _bannerAd;

  @override
  void initState() {
    super.initState();
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(testDeviceIds: ['36bfc7a8e74478142e7d1a56996e0345'])
    );

    _bannerAd = BannerAd(
      adUnitId: Glob.testAdmobBannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    )..load();
  }

  @override
  void dispose() {
    super.dispose();
    _bannerAd.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.11,
      padding: const EdgeInsets.all(10.0),
      child: AdWidget(ad: _bannerAd)
    );
  }
}

