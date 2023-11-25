import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LogoutUtils {
  final BuildContext context;
  final secureStorage = FlutterSecureStorage();

  LogoutUtils(this.context);

  Future<void> logout() async {
    // 로컬에 저장된 토큰 삭제
    await secureStorage.delete(key: 'token');

    // 홈 화면으로 이동
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }
}