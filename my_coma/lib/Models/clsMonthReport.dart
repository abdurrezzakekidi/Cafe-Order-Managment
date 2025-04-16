class MonthlyReport {
  final DateTime day;
  final double dailyRevenue;

  MonthlyReport({required this.day, required this.dailyRevenue});

  factory MonthlyReport.fromJson(Map<String, dynamic> json) {
    return MonthlyReport(
      day: DateTime.parse(json['day']),
      dailyRevenue: json['dailyRevenue'].toDouble(),
    );
  }
}

