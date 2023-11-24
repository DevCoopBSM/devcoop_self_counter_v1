import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../Dto/item_response_dto.dart';
import '../_constant/component/button.dart';
import 'widgets/payments_item.dart';
import 'widgets/payments_popup.dart';

final secureStorage = FlutterSecureStorage();

class PaymentsPage extends StatefulWidget {
  PaymentsPage({Key? key}) : super(key: key);

  @override
  _PaymentsPageState createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  String savedStudentName = '';
  int savedPoint = 0;
  int totalPrice = 0;
  String? savedCodeNumber; // 수정: null 허용
  String? savedUserId; // 수정: null 허용
  List<ItemResponseDto> itemResponses = [];
  TextEditingController barcodeController = TextEditingController();
  FocusNode barcodeFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      setState(() {
        savedPoint = prefs.getInt('point') ?? 0;
        savedStudentName = prefs.getString('studentName') ?? '';
        savedCodeNumber = prefs.getString('codeNumber'); // 수정
        savedUserId = prefs.getString('studentName'); // 수정
      });

      if (savedPoint != 0 && savedStudentName.isNotEmpty) {
        print("Getting UserInfo");
        print('Data loaded from SharedPreferences');
      }

      if (savedCodeNumber == null) {
        print('codeNumber가 설정되지 않았습니다.');
      }
    } catch (e) {
      print('Error during loading data: $e');
    }
  }

  // fetchItemData 함수에서 ItemResponseDto 생성자 호출 시 itemId 추가
  Future<void> fetchItemData(String barcode, int quantity) async {
    try {
      const apiUrl = 'http://localhost:8080/kiosk';
      final response =
          await http.get(Uri.parse('$apiUrl/itemSelect?barcodes=$barcode'));

      print(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> itemJsonList =
            jsonDecode(utf8.decode(response.bodyBytes));
        final Map<String, dynamic> responseBody = itemJsonList.first;
        final String itemName = responseBody['name'];
        final dynamic rawItemPrice = responseBody['price'];
        final String itemPrice =
            rawItemPrice?.toString() ?? '0'; // 수정: null 체크 및 기본값 설정

        setState(() {
          final existingItemIndex = itemResponses.indexWhere(
            (existingItem) => existingItem.itemId == barcode,
          );

          print(existingItemIndex);

          if (existingItemIndex != -1) {
            // 이미 추가된 아이템이 있다면 갯수를 증가시키고 총 가격 업데이트
            final existingItem = itemResponses[existingItemIndex];
            existingItem.quantity += 1;
            totalPrice += existingItem.itemPrice;
            itemResponses[existingItemIndex] = existingItem; // 업데이트된 아이템 다시 저장
          } else {
            // 새로운 아이템 추가
            final item = ItemResponseDto(
              itemName: itemName ?? '',
              itemPrice: int.parse(itemPrice),
              itemId: barcode,
              quantity: 1, // 새로운 아이템의 기본 갯수는 1로 설정
            );
            itemResponses.add(item);
            totalPrice += int.parse(itemPrice);
          }
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void showPaymentsPopup(BuildContext context, int totalPrice) {
    deductPoints();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return paymentsPopUp(context, totalPrice);
      },
    );
  }

  void handleBarcodeSubmit() {
    String barcode = barcodeController.text;

    int quantity = 1;

    if (barcode.isNotEmpty) {
      fetchItemData(
        barcode,
        quantity,
      );

      // 상품 선택 후 바코드 입력창 초기화
      barcodeController.clear();
    }
  }

  Future<void> savePayLog(int totalPrice) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? savedCodeNumber = prefs.getString('codeNumber');
    String? savedStudentName = prefs.getString('studentName');

    if (savedCodeNumber != null && savedStudentName != null) {
      print("Getting UserInfo");
      print('Data loaded from SharedPreferences');
    }

    try {
      const apiUrl = 'http://localhost:8080/kiosk/save/paylog';
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<dynamic, dynamic>{
          "codeNumber": savedCodeNumber,
          "type": 0,
          "innerPoint": totalPrice,
          "chargerId": "kiosk",
          "verifyKey": "test",
          "studentName": savedStudentName,
        }),
      );

      print(response.body);

      if (response.statusCode == 200) {
        // 요청이 성공적으로 처리되었을 때의 동작 추가
        print('Points deducted successfully');
      } else {
        // 요청이 실패했을 때의 동작 추가
        print('Failed to deduct points');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> deductPoints() async {
    try {
      const apiUrl = 'http://localhost:8080/kiosk';

      Map<String, dynamic> requestBody = {
        'codeNumber': savedCodeNumber,
        'totalPrice': totalPrice
      };
      String jsonData = json.encode(requestBody);

      print(jsonData);

      final response = await http.put(
        Uri.parse('$apiUrl/pay'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );

      print(response);

      if (response.statusCode == 200) {
        // 요청이 성공적으로 처리되었을 때의 동작 추가
        print('Points deducted successfully');
      } else {
        // 요청이 실패했을 때의 동작 추가
        print('Failed to deduct points');
      }
    } catch (e) {
      // 예외 처리
      print('Error occurred while deducting points: $e');
    }
  }

  Future<void> sendRequestsForItems(List<ItemResponseDto> items) async {
    for (ItemResponseDto item in items) {
      try {
        if (savedUserId != null) {
          // Check if savedUserId is not null
          const apiUrl = 'http://localhost:8080/kiosk/save/receipt';
          final response = await http.post(
            Uri.parse(apiUrl),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              'itemName': item.itemName,
              'saleQty': item.quantity,
              'dcmSaleAmt': item.itemPrice,
              'userId': savedUserId,
            }),
          );

          print("-----------------");
          print(response.body);

          if (response.statusCode == 200) {
            print("응답상태 : ${response.statusCode}");
            print('${item.itemName}에 대한 영수증이 성공적으로 저장되었습니다.');
          } else {
            print("응답상태 : ${response.statusCode}");
            print('${item.itemName}에 대한 영수증 저장 실패');
          }
        }
      } catch (e) {
        print('영수증을 저장하는 동안 오류가 발생했습니다: $e');
      }
    }
  }

  Future<void> sendPayments(List<ItemResponseDto> items) async {
    try {
      String? token = await secureStorage.read(key: 'token');
      print(token);
      if (token != null) {
        final currentTimeUtc = DateTime.now().toUtc(); // 현재 시각을 UTC로 얻음
        final formattedTimeUtc = currentTimeUtc.toIso8601String(); // UTC 시각을 ISO 8601 형식으로 변환

        const apiUrl = 'http://localhost:8080/kiosk/payments';

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token', // 저장된 토큰을 요청 헤더에 추가
          },
          body: jsonEncode(<String, dynamic>{
            'items': items.map((item) {
              return {
                'itemName': item.itemName,
                'saleQty': item.quantity,
                'dcmSaleAmt': item.itemPrice,
              };
            }).toList(),
            'requestTimeUtc': formattedTimeUtc, // UTC 시각을 요청 시각으로 추가
          }),
        );

        print("-----------------");
        print(response.body);

        if (response.statusCode == 200) {
          print("응답상태 : ${response.statusCode}");
          print('구매요청을 성공적으로 보냈습니다.');
        } else {
          print("응답상태 : ${response.statusCode}");
          print('구매요청 실패 실패');
        }
      }
    } catch (e) {
      print('구매요청하는 동안 오류가 발생했습니다: $e');
    }
  }


  @override
  void dispose() {
    barcodeController.dispose();
    barcodeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    FocusScope.of(context).requestFocus(barcodeFocusNode);
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // 다른 곳을 탭하면 포커스 해제
          barcodeFocusNode.unfocus();
        },
        child: Container(
          margin: const EdgeInsets.symmetric(
            vertical: 50,
            horizontal: 90,
          ),
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '$savedStudentName 학생  |  $savedPoint 원',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: TextFormField(
                      // TextFormField로 변경
                      controller: barcodeController,
                      focusNode: barcodeFocusNode,
                      decoration: const InputDecoration(
                        hintText: '바코드 입력',
                      ),
                      onFieldSubmitted: (_) {
                        handleBarcodeSubmit();
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  mainTextButton(
                    text: '상품선택',
                    onTap: () {
                      handleBarcodeSubmit();
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 40,
              ),
              const Divider(
                color: Colors.black,
                thickness: 4,
                height: 4,
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 30,
                  ),
                  child: Column(
                    children: [
                      paymentsItem(
                        left: '상품 이름',
                        center: '수량',
                        rightText: '상품 가격',
                        contentsTitle: true,
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              for (int i = 0;
                                  i < itemResponses.length;
                                  i++) ...[
                                paymentsItem(
                                  left: itemResponses[i].itemName ?? '',
                                  center: '${itemResponses[i].quantity}',
                                  rightText:
                                      itemResponses[i].itemPrice?.toString() ??
                                          '0',
                                  totalText: false,
                                ),
                                if (i < itemResponses.length - 1) ...[
                                  const SizedBox(
                                    height: 15,
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(
                color: Colors.black,
                thickness: 4,
                height: 4,
              ),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 40,
                      ),
                      child: paymentsItem(
                        left: '총 상품 개수 및 합계',
                        center: itemResponses
                            .map<int>((item) => item.quantity)
                            .fold<int>(
                                0,
                                (previousValue, element) =>
                                    previousValue + element)
                            .toString(),
                        rightText: totalPrice.toString(), // 수정: 값을 String으로 변환
                      ),
                    ),
                    mainTextButton(
                      text: '계산하기',
                      onTap: () {
                        sendPayments(itemResponses);
                        sendRequestsForItems(itemResponses);
                        savePayLog(totalPrice);
                        showPaymentsPopup(context, totalPrice);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
