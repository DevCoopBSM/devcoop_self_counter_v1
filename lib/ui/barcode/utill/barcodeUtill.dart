import 'dart:convert';


import 'package:flutter/services.dart';
import 'package:counter/controller/save_user_info.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class BarcodePage extends StatefulWidget {
  const BarcodePage({Key? key}) : super(key: key);

  @override
  _BarcodePageState createState() => _BarcodePageState();
}

class _BarcodePageState extends State<BarcodePage> {
  final TextEditingController _codeNumberController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _barcodeFocus = FocusNode();
  TextEditingController? _activeController;
  final secureStorage = FlutterSecureStorage();


  void onNumberButtonPressed(int number) {
  if (_activeController != null) {
    String currentText = _activeController!.text;

    if (number == 10) {
      _activeController!.clear(); // Clear focus and text
    } else if (number == 12) {
      // Del button
      if (currentText.isNotEmpty) {
        String newText = currentText.substring(0, currentText.length - 1);
        _activeController!.text = newText;
      }
    } else {
      String newText = currentText + (number == 11 ? '0' : number.toString());
      _activeController!.text = newText;
    }
  }
}


void _setActiveController(TextEditingController controller) {
  setState(() {
    _activeController = controller;
  });
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

      String? token = responseBody['data']['token'];
      int point = responseBody['data']['point'];
      String studentName = responseBody['data']['studentName'];
      await secureStorage.write(key: 'token', value: token);
      saveUserData(codeNumber, point, studentName);

      print("로그인 후 사용자 정보 저장성공");

      Get.toNamed('/check');
    }
  } catch (e) {
    print(e);
  }
}