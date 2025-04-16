class clsReport {
  final String productName;
  final int quantity;
  final double totalAmount;

  clsReport({
    required this.productName,
    required this.quantity,
    required this.totalAmount,
  });

  // Method to convert JSON into clsReport object
  factory clsReport.fromJson(Map<String, dynamic> json) {
    return clsReport(
      productName: json['productName'],
      quantity: json['quantity'],
      totalAmount: json['totalAmount'].toDouble(),
    );
  }
}
