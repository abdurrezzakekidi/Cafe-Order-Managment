import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_coma/Models/API.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:my_coma/Models/clsReport.dart';
import 'package:my_coma/generated/l10n.dart';

class TodayReportPage extends StatefulWidget {
  const TodayReportPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TodayReportPageState createState() => _TodayReportPageState();
}

class _TodayReportPageState extends State<TodayReportPage> {
  List<clsReport> todayReportData = [];
  String selectedProductName = '';
  double _totalAmount = 0;
  String _message ="";

  @override
  void initState() {
    super.initState();
    _fetchTodayReport();
  }

  Future<void> _fetchTodayReport() async {
    final response = await http.get(Uri.parse('${clsAPI.baseURL}/${clsAPI.D_REPORT}'));

    if (response.statusCode == 200) {
      setState(() {
        List jsonResponse = json.decode(response.body);
        todayReportData = jsonResponse.map((data) => clsReport.fromJson(data)).toList();
        todayReportData.sort((a, b) => a.quantity.compareTo(b.quantity));
        _countTotalAmount();
      });
    }else if(response.statusCode == 404){
      setState(() {
        todayReportData = [];
        _message = S.of(context).scnDDS;
      });
    }  
    else {
      setState(() {
        todayReportData = [];
        _message = S.of(context).scnLA;
      });  
    }
  }

  void _countTotalAmount() {
    _totalAmount = todayReportData.fold(0, (sum, data) => sum + data.totalAmount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          selectedProductName.isEmpty ? S.of(context).scnDD : selectedProductName,
          style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
        ),
        backgroundColor: const Color.fromRGBO(26, 35, 126, 1),
        centerTitle: true,
      ),
      body: todayReportData.isEmpty
          ? _message.isEmpty ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Color.fromRGBO(26, 35, 126, 1)),
                  const SizedBox(height: 10),
                  Text(
                    S.of(context).scnDL,
                    style: const TextStyle(fontSize: 16, color: Color.fromRGBO(26, 35, 126, 1)),
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
      child: SfCartesianChart(
        borderColor: Colors.grey.shade300,
        borderWidth: 1,
        primaryXAxis: CategoryAxis(
          isVisible: false,
          axisLine: const AxisLine(color: Colors.transparent),
          majorTickLines: const MajorTickLines(color: Colors.transparent),
        ),
        primaryYAxis: NumericAxis(
          title: AxisTitle(
            text: "${S.of(context).scnDDT} : $_totalAmount",
            textStyle: const TextStyle(color: Color.fromRGBO(26, 35, 126, 1), fontSize: 14),
          ),
          axisLine: const AxisLine(color: Colors.transparent),
          majorTickLines: MajorTickLines(color: Colors.grey.shade400),
        ),
        tooltipBehavior: TooltipBehavior(enable: true, color: Colors.blue.shade100),
       series: <CartesianSeries<clsReport, String>>[
         ColumnSeries<clsReport, String>(
           dataSource: todayReportData,
           xValueMapper: (clsReport report, _) => report.productName,
           yValueMapper: (clsReport report, _) => report.totalAmount.toDouble(),
           color: const Color.fromRGBO(26, 35, 126, 1),
           borderRadius: BorderRadius.circular(8), // Güncellenmiş hali
           dataLabelSettings: DataLabelSettings(
             isVisible: true,
             textStyle: TextStyle(color: Colors.grey.shade100, fontSize: 12),
           ),
         ),
       ],
        onSelectionChanged: (SelectionArgs args) {
          if (args.pointIndex < todayReportData.length) {
            setState(() {
              selectedProductName = todayReportData[args.pointIndex].productName;
            });
          }
        },
      ),
    );
  }
}
