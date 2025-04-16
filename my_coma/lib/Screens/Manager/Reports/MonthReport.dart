import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_coma/Models/API.dart';
import 'package:my_coma/Models/clsMonthReport.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart'; // Tarih formatlama için gerekli
import 'package:my_coma/generated/l10n.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';


class MonthlyReportPage extends StatefulWidget {
  const MonthlyReportPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MonthlyReportPageState createState() => _MonthlyReportPageState();
}

class _MonthlyReportPageState extends State<MonthlyReportPage> {
  List<MonthlyReport> monthlyReportData = [];
  double _totalMonthlyAmount = 0;
  String _message = "";

  @override
  void initState() {
    super.initState();
    _fetchMonthlyReport();
  }

  Future<void> _fetchMonthlyReport() async {
    final response = await http.get(Uri.parse('${clsAPI.baseURL}/${clsAPI.M_REPORT}'));

    if (response.statusCode == 200) {
      setState(() {
        List jsonResponse = json.decode(response.body);
        monthlyReportData = jsonResponse.map((data) => MonthlyReport.fromJson(data)).toList();
        _calculateTotalMonthlyRevenue();
      });
    }else if(response.statusCode == 404)
    {
      setState(() {
        monthlyReportData = [];
        _message = S.of(context).scnDDS;
      });
    } 
    else {
      setState(() {
        monthlyReportData = [];
        _message = S.of(context).scnLA;
      });
    }
  }

  void _calculateTotalMonthlyRevenue() {
    for(int i = 0;i<monthlyReportData.length;i++)
    {
      _totalMonthlyAmount += monthlyReportData[i].dailyRevenue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(S.of(context).scnDM , style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
        backgroundColor: const Color.fromRGBO(26, 35, 126, 1),
        centerTitle: true,
      ),
      body: monthlyReportData.isEmpty
          ? _message.isEmpty ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color:  Color.fromRGBO(26, 35, 126, 1)),
                  const SizedBox(height: 10),
                  Text(
                    S.of(context).scnDL,
                    style: const TextStyle(fontSize: 16, color:  Color.fromRGBO(26, 35, 126, 1)),
                  ),
                ],
              ),
            ) : Center(
              child: Text(_message),
            )
          : _buildChart(),
    );
  }

  Widget _buildChart() {
  return Padding(
    padding: const EdgeInsets.all(20.0),
    child: Stack(
      alignment: Alignment.topCenter, // Metni grafiğin üst kısmına hizalar
      children: [
        SfCartesianChart(
          borderColor: Colors.grey.shade300,
          borderWidth: 1,
          primaryXAxis: DateTimeAxis(
            title: AxisTitle(
              text: S.of(context).scnDMDD,
              textStyle: const TextStyle(color: Color.fromRGBO(26, 35, 126, 1)),
            ),
            dateFormat: DateFormat('d'), // Tarihi sadece gün olarak göstermek için
            intervalType: DateTimeIntervalType.days,
            axisLine: const AxisLine(color: Colors.transparent),
            majorTickLines: const MajorTickLines(color: Colors.transparent),
          ),
          primaryYAxis: NumericAxis(
            title: AxisTitle(
              text: S.of(context).scnDMDI,
              textStyle: const TextStyle(color: Color.fromRGBO(26, 35, 126, 1)),
            ),
            axisLine: const AxisLine(color: Colors.transparent),
            majorTickLines: MajorTickLines(color: Colors.grey.shade400),
          ),
          tooltipBehavior: TooltipBehavior(enable: true, color: Colors.blue.shade100),
         series: <CartesianSeries<MonthlyReport, DateTime>>[
           LineSeries<MonthlyReport, DateTime>(
             dataSource: monthlyReportData,
             xValueMapper: (MonthlyReport report, _) => report.day,
             yValueMapper: (MonthlyReport report, _) => report.dailyRevenue,
             color: const Color.fromRGBO(26, 35, 126, 1),
             markerSettings: const MarkerSettings(isVisible: true),
             dataLabelSettings: DataLabelSettings(
               isVisible: true,
               textStyle: TextStyle(color: Colors.grey.shade100, fontSize: 12),
         ),
         ),
         ],
        ),
        Positioned(
          top: 10, // Grafiğin üst kısmında sabit bir boşluk bırak
          child: Text(
            '${S.of(context).scnDMMI} ${_totalMonthlyAmount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),
      ],
    ),
  );
}
}


