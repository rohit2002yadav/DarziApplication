class Order {
  final String id;
  final String garmentType;
  final String fabricOption;
  final String status;

  Order({
    required this.id,
    required this.garmentType,
    required this.fabricOption,
    required this.status,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'],
      garmentType: json['garmentType'],
      fabricOption: json['fabricOption'],
      status: json['status'],
    );
  }
}
