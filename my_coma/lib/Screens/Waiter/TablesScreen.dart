import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_coma/Models/API.dart';
import '../../Models/clsTable.dart';
import 'ProductsScreen.dart'; // Ürünleri gösterecek olan ekranı import edin
import 'package:my_coma/generated/l10n.dart';

class TablesScreen extends StatefulWidget {
  const TablesScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TablesScreenState createState() => _TablesScreenState();
}

class _TablesScreenState extends State<TablesScreen> {
  List<clsTable> tables = [];
  List<clsTable> filteredTables = [];
  List<clsTable> dataShow = [];
  String searchQuery = "";
  String errorMessage = '';
  @override
  void initState() {
    super.initState();
    fetchTables();
  }

  // API'dan masaları çekme
  Future<void> fetchTables() async {
    final response = await http.get(Uri.parse('${clsAPI.baseURL}/${clsAPI.TABLES}'));

    if (response.statusCode == 200) {
      setState(() {
          errorMessage = '';
        });
      List jsonResponse = json.decode(response.body);
      setState(() {
        tables = jsonResponse.map((data) => clsTable.fromJson(data)).toList();
      });
    } else {
      setState(() {
          errorMessage = S.of(context).scnDTF;
        });
    }
    dataShow = tables;
  }


  void filterTables(String query) {
    setState(() {
      searchQuery = query;
      filteredTables = tables
          .where((table) => table.no.toString().toLowerCase().contains(query.toLowerCase()))
          .toList();

          dataShow = filteredTables;
          errorMessage = S.of(context).scnTE;
    });
  }

  

  @override
  Widget build(BuildContext context) {

    final locale = Localizations.localeOf(context).languageCode; // Geçerli dil kodu


    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).scnT),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: filterTables,
            decoration: InputDecoration(
              hintText: S.of(context).scnDTS,
              prefixIcon: Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ),
      ),
      body: dataShow.isEmpty
          ? (errorMessage.isEmpty ? Center(child: CircularProgressIndicator()) : Center(
            child: Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red),
                      ),
          ) )// Yükleniyor göstergesi
          : ListView.builder(
              itemCount: dataShow.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    leading: Icon(Icons.table_restaurant, size: 40, color: Colors.green),
                    title: Text('${S.of(context).scnDTN}: ${dataShow[index].no}', style: TextStyle(fontSize: 18)),
                    subtitle: Text('${S.of(context).scnDPPS}: ${locale == 'tr' ? dataShow[index].status : (locale == 'en'? (dataShow[index].status == 'Dolu' ? 'Full' : 'Empty'):(dataShow[index].status == 'Dolu' ? 'ممتلئ' : 'فارغ') )}', style: TextStyle(fontSize: 16)),
                    trailing: dataShow[index].status == "Bos"
                        ? Icon(Icons.check_circle, color: Colors.green)
                        : Icon(Icons.cancel, color: Colors.red),
                    onTap: () {
                      // Masa tıklandığında ürün ekranına git ve geri dönüldüğünde masaları yenile
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductsScreen(tableId: dataShow[index].id),
                        ),
                      ).then((_) {
                        // Geri dönüldüğünde masalar listesini yenile
                        fetchTables();
                      });
                    },
                  ),
                );
              },
            ),
    );
  }
}