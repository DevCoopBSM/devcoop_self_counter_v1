import 'package:counter/ui/_constant/theme/devcoop_text_style.dart';
import 'package:flutter/material.dart';
import 'package:counter/ui/_constant/theme/devcoop_colors.dart';
import 'package:get/get.dart';

class MyHome extends StatelessWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Get.offAllNamed('/barcode');
        },
        child: Container(
          margin: const EdgeInsets.only(top: 500), // 사용자 지정 단위로 마진 설정
          child: Center(
            child: Text(
              'touch to start',
              style: DevCoopTextStyle.bold_50.copyWith(
                color: DevCoopColors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
