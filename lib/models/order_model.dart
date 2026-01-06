class Order {
  final String id;

  final String customerName;
  final String customerPhone;
  final String? customerEmail;

  final String tailorId;
  final String garmentType;

  final List<String> items;
  final Map<String, dynamic> measurements;

  final String handoverType; // pickup | drop

  final String? pickupAddress;
  final String? pickupDate;
  final String? pickupTime;

  final double totalAmount;
  final String status;

  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    this.customerEmail,
    required this.tailorId,
    required this.garmentType,
    required this.items,
    required this.measurements,
    required this.handoverType,
    this.pickupAddress,
    this.pickupDate,
    this.pickupTime,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final pickup = json['pickup'] ?? {};

    return Order(
      id: json['_id'] ?? '',

      customerName: json['customerName'] ?? 'Guest',
      customerPhone: json['customerPhone'] ?? '',
      customerEmail: json['customerEmail'],

      tailorId: json['tailorId'] is Map
          ? json['tailorId']['_id']
          : json['tailorId'] ?? '',

      garmentType: json['garmentType'] ?? '',

      items: List<String>.from(json['items'] ?? []),

      measurements:
      json['measurements'] != null
          ? Map<String, dynamic>.from(json['measurements'])
          : {},

      handoverType: json['handoverType'] ?? 'drop',

      pickupAddress: pickup['address'],
      pickupDate: pickup['date'],
      pickupTime: pickup['time'],

      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: json['status'] ?? 'PLACED',

      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// Use ONLY if you resend order data to backend
  Map<String, dynamic> toJson() {
    return {
      "customerName": customerName,
      "customerPhone": customerPhone,
      "customerEmail": customerEmail,
      "tailorId": tailorId,
      "garmentType": garmentType,
      "items": items,
      "measurements": measurements,
      "handoverType": handoverType,
      "pickup": handoverType == "pickup"
          ? {
        "address": pickupAddress,
        "date": pickupDate,
        "time": pickupTime,
      }
          : null,
      "totalAmount": totalAmount,
    };
  }
}
