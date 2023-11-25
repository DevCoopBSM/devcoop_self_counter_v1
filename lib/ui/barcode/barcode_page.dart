import 'dart:convert';

import 'package:counter/ui/_constant/component/button.dart';
import 'package:counter/ui/_constant/theme/devcoop_text_style.dart';
import 'package:counter/ui/_constant/theme/devcoop_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:counter/controller/save_user_info.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';

class BarcodePage extends StatefulWidget {
  const BarcodePage({Key? key}) : super(key: key);

  @override
  _BarcodePageState createState() => _BarcodePageState();
}

class _BarcodePageState extends State<BarcodePage> {

  final List<int?> pinNumbers = List.filled(6, null); // 초기에 null로 채워진 길이 6의 배열
  int currentDigitIndex = 0; // 현재 입력 중인 자릿수 인덱스

  final TextEditingController _codeNumberController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _barcodeFocus = FocusNode();
  TextEditingController? _activeController;
  final secureStorage = FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(_barcodeFocus);
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 30,
          horizontal: 90,
        ),
        alignment: Alignment.center,
        child: Column(
          children: [
            Text(
              "학생증의 바코드를\n리더기로 스캔해주세요.",
              style: DevCoopTextStyle.bold_40.copyWith(
                color: DevCoopColors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 40,
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      for (int i = 0; i < 4; i++) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            for (int j = 0; j < 3; j++) ...[
                              GestureDetector(
                                onTap: () {
                                  int _number = j + 1 + i * 3;
                                  onNumberButtonPressed(_number);
                                },
                                child: Container(
                                  width: 95,
                                  height: 95,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: (j + 1 + i * 3 == 10 ||
                                        j + 1 + i * 3 == 12)
                                        ? DevCoopColors.primary
                                        : const Color(0xFFD9D9D9),
                                  ),
                                  child: Text(
                                    '${j + 1 + i * 3 == 10 ? 'Clear' : (j + 1 + i * 3 == 11 ? '0' : (j + 1 + i * 3 == 12 ? 'Del' : j + 1 + i * 3))}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      color: DevCoopColors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (i < 3) ...[
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 160,
                            child: Text(
                              '학생증 번호',
                              style: DevCoopTextStyle.medium_30.copyWith(
                                color: DevCoopColors.black,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                _setActiveController(_codeNumberController);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 34,
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xFFECECEC),
                                  borderRadius: BorderRadius.circular(
                                    20,
                                  ),
                                ),
                                child: TextField(
                                  controller: _codeNumberController,
                                  focusNode: _barcodeFocus,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(
                                        '[0-9]',
                                      ),
                                    ),
                                  ],
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                    hintText: '학생증을 리더기에 스캔해주세요',
                                    hintStyle: DevCoopTextStyle.medium_30
                                        .copyWith(fontSize: 15),
                                    border: InputBorder.none,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 60,
                      ),
                      Row(
                        children: [
                          Container(
                            width: 160,
                            alignment: Alignment.center,
                            child: Text(
                              '핀 번호',
                              style: DevCoopTextStyle.medium_30.copyWith(
                                color: DevCoopColors.black,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 34,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECECEC),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  for (int i = 0; i < 6; i++) ...[
                                    Container(
                                      width: 40, // 각 핀 번호의 크기를 조정
                                      height: 40, // 각 핀 번호의 크기를 조정
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: DevCoopColors.black,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        pinNumbers[i] != null
                                            ? '*' // 핀 번호를 *로 표시
                                            : '',
                                        style: const TextStyle(
                                          fontSize: 18, // 글자 크기를 조정
                                          color: DevCoopColors.black,
                                        ),
                                      ),
                                    ),
                                    if (i < 5) const SizedBox(width: 10),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Container(margin: EdgeInsets.only(left: 210)),
                mainTextButton(
                  text: '확인',
                  onTap: () {
                    _login(context);
                  },
                ),
                const SizedBox(
                  width: 210,
                ),
                mainTextButton(
                  text: '처음으로',
                  onTap: () {
                    Get.toNamed('/home');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  void onNumberButtonPressed(int number) {
    if (number == 10) {
      // Clear button
      for (int i = 0; i < 6; i++) {
        pinNumbers[i] = null; // 모든 핀 번호 초기화
      }
      currentDigitIndex = 0; // 첫 번째 자릿수부터 다시 시작
    } else if (number == 12) {
      // Del button
      if (currentDigitIndex > 0) {
        // 현재 자릿수에서 숫자 삭제
        currentDigitIndex--;
        pinNumbers[currentDigitIndex] = null;
      }
    } else {
      // 숫자 버튼
      if (currentDigitIndex < 6 && pinNumbers[currentDigitIndex] == null) {
        // 핀 번호 배열에 숫자 추가
        pinNumbers[currentDigitIndex] = number;
        currentDigitIndex++;
      }
    }
    setState(() {}); // 화면 갱신
  }
  void _setActiveController(TextEditingController controller) {
    setState(() {
      _activeController = controller;
    });
  }
  void _showErrorDialog(String errorMessage) {
    print("Dialog Start");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '에러 발생',
            style: DevCoopTextStyle.bold_30.copyWith(
              color: Colors.black, // 글자 색상 설정
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.all(20.0), // 내용 주위 여백 조절
            child: Text(
              errorMessage,
              style: DevCoopTextStyle.medium_30.copyWith(
                fontSize: 20.0, // 글자 크기 조정
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.amber), // 배경 색상을 노란색으로 설정
                minimumSize: MaterialStateProperty.all(const Size(120, 60)),
              ),
              child: Text(
                '확인',
                style: DevCoopTextStyle.bold_40.copyWith(
                  color: Colors.black, // 글자 색상 설정
                  fontSize: 24, // 글자 크기 조정
                ),
              ),
            ),
          ],
        );
      },
    );
  }



  Future<void> _login(BuildContext context) async {
    String codeNumber = _codeNumberController.text;
    String pin = _pinController.text;

    Map<String, String> requestBody = {'codeNumber': codeNumber, 'pin': pin};
    String jsonData = json.encode(requestBody);

    String apiUrl = 'http://localhost:8080/kiosk/auth/signIn';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: jsonData,
      );

      if (response.statusCode == 200) {
        print("로그인 성공");

        Map<String, dynamic> responseBody =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

        // JSON 데이터를 가독성 있게 출력
        JsonEncoder encoder = JsonEncoder.withIndent('  ');
        String prettyPrinted = encoder.convert(responseBody);
        print(prettyPrinted);


        String? token = responseBody['token'];
        int point = responseBody['point'];
        String studentName = responseBody['studentName'];
        await secureStorage.write(key: 'token', value: token);
        saveUserData(codeNumber, point, studentName);

        print("로그인 후 사용자 정보 저장성공");

        Get.toNamed('/check');
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        // 로그인 실패 시 에러 메시지를 표시

        _showErrorDialog("학생증 혹은 핀번호를 다시 확인해주세요");
      }
    } catch (e) {
      _showErrorDialog("내부 서버 오류");
      print(e);
    }
  }
}
