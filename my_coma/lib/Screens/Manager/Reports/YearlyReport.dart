import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_coma/Models/API.dart';
import 'package:my_coma/Models/clsYearlyReport.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:my_coma/generated/l10n.dart';

class YearlyReportPage extends StatefulWidget {
  const YearlyReportPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _YearlyReportPageState createState() => _YearlyReportPageState();
}

class _YearlyReportPageState extends State<YearlyReportPage> {
  List<YearlyReport> yearlyReportData = [];
  String _message = "";
  double _totalYearlyAmount = 0;
 
  @override
  void initState() {
    super.initState();
    _fetchYearlyReport();
  }

  Future<void> _fetchYearlyReport() async {
    final response = await http.get(Uri.parse('${clsAPI.baseURL}/${clsAPI.Y_REPORT}'));

    if (response.statusCode == 200) {
      setState(() {
        List jsonResponse = json.decode(response.body);
        yearlyReportData = jsonResponse.map((data) => YearlyReport.fromJson(data)).toList();
        _calculateTotalYearlyRevenue();
      });
    } else if(response.statusCode == 404){
      setState(() {
        yearlyReportData = [];
        _message = S.of(context).scnDDS;
      });
    }
    else {
      setState(() {
        yearlyReportData = [];
        _message = S.of(context).scnLA;
      });
    }
  }

  void _calculateTotalYearlyRevenue()
  {
    for(int i = 0;i<yearlyReportData.length;i++)
    {
      _totalYearlyAmount += yearlyReportData[i].monthlyRevenue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(S.of(context).scnDY, style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
        backgroundColor: const Color.fromRGBO(26, 35, 126, 1),
        centerTitle: true,
      ),
      body: yearlyReportData.isEmpty
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
          primaryXAxis: CategoryAxis(
            title: AxisTitle(
              text: S.of(context).scnDMDM,
              textStyle: const TextStyle(color: Color.fromRGBO(26, 35, 126, 1)),
            ),
            axisLine: const AxisLine(color: Colors.transparent),
            majorTickLines: const MajorTickLines(color: Colors.transparent),
          ),
          primaryYAxis: NumericAxis(
            title: AxisTitle(
              text: S.of(context).scnDMMI,
              textStyle: const TextStyle(color: Color.fromRGBO(26, 35, 126, 1)),
            ),
            axisLine: const AxisLine(color: Colors.transparent),
            majorTickLines: MajorTickLines(color: Colors.grey.shade400),
          ),
          tooltipBehavior: TooltipBehavior(enable: true, color: Colors.blue.shade100),
         series: <CartesianSeries<YearlyReport, String>>[
           ColumnSeries<YearlyReport, String>(
             dataSource: yearlyReportData,
             xValueMapper: (YearlyReport report, _) => report.monthName, // Ay ismi X ekseni için
             yValueMapper: (YearlyReport report, _) => report.monthlyRevenue, // Aylık gelir Y ekseni için
             color: const Color.fromRGBO(26, 35, 126, 1),
             borderRadius: BorderRadius.circular(5),
             dataLabelSettings: DataLabelSettings(
               isVisible: true,
               textStyle: TextStyle(color: Colors.grey.shade100, fontSize: 12),
             ),
           ),
         ],
        ),
        // Grafiğin üstüne toplam yıllık geliri yazıyoruz
        Positioned(
          top: 10, // Grafiğin üstünden 10 piksel boşluk bırak
          child: Text(
            '${S.of(context).scnDMYI} ${_totalYearlyAmount.toStringAsFixed(2)}',
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

