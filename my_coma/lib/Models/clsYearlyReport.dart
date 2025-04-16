class YearlyReport {
  final String monthName;
  final int monthNumber;
  final double monthlyRevenue;

  YearlyReport({
    required this.monthName,
    required this.monthNumber,
    required this.monthlyRevenue,
  });

  factory YearlyReport.fromJson(Map<String, dynamic> json) {
    return YearlyReport(
      monthName: json['monthName'],
      monthNumber: json['monthNumber'],
      monthlyRevenue: json['monthlyRevenue'].toDouble(),
    );
  }
}
