import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../Models/clsCashierTable.dart';
import 'TableOrdersScreen.dart';
import 'package:my_coma/Models/API.dart';
import 'package:my_coma/generated/l10n.dart';

class CashierTablesScreen extends StatefulWidget {
  const CashierTablesScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CashierTablesScreenState createState() => _CashierTablesScreenState();
}

class _CashierTablesScreenState extends State<CashierTablesScreen> {
  List<clsCashierTable> tables = [];
  String message = "";
  String searchQuery = '';
  List<clsCashierTable> filteredTables = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchTables();
  }

  Future<void> fetchTables() async {
    final response = await http.get(Uri.parse('${clsAPI.baseURL}/${clsAPI.TABLES}'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      setState(() {
        tables = jsonResponse.map((data) => clsCashierTable.fromJson(data)).toList();
        filteredTables = tables;
      });
    } else {
      setState(() {
        message = S.of(context).scnC;
      });
    }
  }

  void filterTables(String query) {
    setState(() {
      searchQuery = query;
      filteredTables = tables.where((table) => table.no.toString().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).scnDT, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueGrey,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Arama çubuğu
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: filterTables,
              decoration: InputDecoration(
                hintText: S.of(context).scnDTS,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          // Masa listesi
          Expanded(
            child: tables.isEmpty
                ? Center(
                    child: message.isNotEmpty
                        ? Text(message)
                        : const CircularProgressIndicator(),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3 / 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filteredTables.length,
                    itemBuilder: (context, index) {
                      final table = filteredTables[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TableOrdersScreen(tableId: table.id),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.blueGrey, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.table_restaurant,
                                  size: 50,
                                  color: Colors.blueGrey,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '${S.of(context).scnt} ${table.no}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.blueGrey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
