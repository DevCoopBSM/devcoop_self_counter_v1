class ItemResponseDto {
  final String itemName;
  late final int itemPrice; // 타입을 int로 변경
  final String itemBarcode;
  int quantity;
  int itemTotalPrice;

  ItemResponseDto({
    required this.itemName,
    required this.itemPrice,
    required this.itemBarcode,
    required this.quantity,
    required this.itemTotalPrice,
  });

  factory ItemResponseDto.fromJson(Map<String, dynamic> json) {
    return ItemResponseDto(
      itemName: json['name'],
      itemPrice: json['price'] ?? 0, // null 처리
      itemBarcode: json['itemBarcode'] , // notnull
      quantity: json['quantity'] ?? 0, // null 처리 또는 기본값 지정
      itemTotalPrice: json['itemTotalPrice'] ?? 0, // null 처리
    );
  }
}
