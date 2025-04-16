class Order {
  final int id;
  final int tableId;
  final int productId;
  final String status;

  Order({required this.id, required this.tableId, required this.productId, required this.status});

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      tableId: json['tableId'],
      productId: json['productId'],
      status: json['status'],
    );
  }
}
