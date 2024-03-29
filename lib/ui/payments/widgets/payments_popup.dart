import 'package:counter/ui/_constant/theme/devcoop_colors.dart';
import 'package:counter/ui/_constant/theme/devcoop_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> removeUserData() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('codeNumber');
    prefs.remove('pin');
    prefs.remove('point');
    prefs.remove('studentName');
  } catch (e) {
    print(e);
  }
}

void navigateToNextPage() {
  // Use Navigator to push a new page
  Get.offAllNamed('/');
}

AlertDialog paymentsPopUp(BuildContext context, int totalPrice, int leftPoint) {
  // Delayed navigation after 3 seconds
  Future.delayed(const Duration(seconds: 3), () {
    removeUserData();
    navigateToNextPage();
  });

  return AlertDialog(
    content: Container(
      width: 520,
      height: 320,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$totalPrice원 결제되었습니다',
            style: DevCoopTextStyle.light_40.copyWith(
              color: DevCoopColors.black,
              fontSize: 24,
            ),
          ),
          Text(
            '남은 포인트는 $leftPoint 입니다',
            style: DevCoopTextStyle.light_40.copyWith(
              color: DevCoopColors.black,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            "잠시후에 처음화면으로 돌아갑니다",
            style: DevCoopTextStyle.medium_30.copyWith(
              color: DevCoopColors.black,
            ),
          ),
        ],
      ),
    ),
  );
}
