import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../_constant/theme/devcoop_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckStudent extends StatefulWidget {
  const CheckStudent({Key? key}) : super(key: key);

  @override
  State<CheckStudent> createState() => _CheckStudentState();
}

class _CheckStudentState extends State<CheckStudent> {
  late String savedStudentName = '';
  late int savedPoint = 0;
  late String savedCodeNumber = '';

  @override
  void initState() {
    super.initState();
    loadUserData();

    // Delayed navigation after 5 seconds
    Future.delayed(const Duration(seconds: 3), () {
      navigateToNextPage();
    });
  }

  void navigateToNextPage() {
    Get.toNamed('/payments');
  }

  Future<void> loadUserData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final String? loadedStudentName = prefs.getString('studentName');
      final int loadedPoint = prefs.getInt('point') ?? 0;
      final String? loadedCodeNumber = prefs.getString('codeNumber');

      if (loadedCodeNumber != null && loadedCodeNumber.isNotEmpty) {
        print("Getting UserInfo");
        print('Data loaded from SharedPreferences');

        setState(() {
          savedStudentName = loadedStudentName!;
          savedPoint = loadedPoint;
          savedCodeNumber = loadedCodeNumber;
        });
      }
    } catch (e) {
      print('에러발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 24),
              child: Text(
                // TODO : savedStudentName 한글이 깨져서 나오는 현상 수정
                '${savedStudentName} 학생 \n 잔액 ${savedPoint}원 조회되었습니다',
                textAlign: TextAlign.center,
                style: GoogleFonts.nanumGothic(
                  fontSize: 30,
                  color: DevCoopColors.black,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 32),
              child: Image.asset(
                'assets/images/accept.png',
                width: 200,
                height: 200,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
