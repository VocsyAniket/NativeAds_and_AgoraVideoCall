import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ads.dart';

class NativeAds extends StatelessWidget {
  const NativeAds({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Obx((){
        if (nativeAdIsLoaded.value == true) {
          return AdWidget(ad: nativeAd!);
        } else {
          return const SizedBox.shrink();
        }
      }),
    );
  }
}
