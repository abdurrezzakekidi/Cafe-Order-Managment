class clsTableOrders {
  final String name;
  final double price;

  clsTableOrders({required this.name, required this.price});

  factory clsTableOrders.fromJson(Map<String, dynamic> json) {
    return clsTableOrders(
      name: json['name'],
      price: json['price'],
    );
  }
}