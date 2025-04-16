class clsOrders {
  final int tableNo;
  final String orderName;
  final int orderId;
  final String orderStatus;

  clsOrders({required this.tableNo, required this.orderName, required this.orderId, required this.orderStatus});

  factory clsOrders.fromJson(Map<String, dynamic> json) {
    return clsOrders(
      tableNo: json['no'],
      orderName: json['name'],
      orderId: json['id'],
      orderStatus: json['status'],
    );
  }
}
