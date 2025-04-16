import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_coma/Models/API.dart';
import 'package:my_coma/Screens/Manager/Tables/AddNewTablePage.dart';
import 'package:my_coma/Screens/Manager/Tables/UpdateTablePage.dart';
import 'package:my_coma/generated/l10n.dart';

class TablesPage extends StatefulWidget {
  const TablesPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TablesPageState createState() => _TablesPageState();
}

class _TablesPageState extends State<TablesPage> {
  List _tables = [];
  List _filteredTables = [];
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    _fetchTables();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchTables() async {
    final response = await http.get(Uri.parse('${clsAPI.baseURL}/${clsAPI.TABLES}'));

    if (response.statusCode == 200) {
      setState(() {
        _tables = json.decode(response.body);
        _filteredTables = _tables;
      });
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        // ignore: use_build_context_synchronously
        SnackBar(content: Text(S.of(context).scnDTF),backgroundColor: Colors.red,),
      );
    }
  }

  void _filterTables(String query) {
    final filtered = _tables.where((table) {
      final tableNo = table['no'].toString().toLowerCase();
      final input = query.toLowerCase();
      return tableNo.contains(input);
    }).toList();

    setState(() {
      _filteredTables = filtered;
    });
  }

  Future<void> _deleteTable(int id) async {
    final response = await http.delete(Uri.parse('${clsAPI.baseURL}/${clsAPI.TABLE}/$id'));

    if (response.statusCode == 200) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        // ignore: use_build_context_synchronously
        SnackBar(content: Text(S.of(context).scnDUD),backgroundColor: Colors.green,),
      );
      _fetchTables(); // Sayfanın yenilenmesi için tabloları tekrar getiriyoruz
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        // ignore: use_build_context_synchronously
        SnackBar(content: Text(S.of(context).scnDE),backgroundColor: Colors.red,),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    final locale = Localizations.localeOf(context).languageCode; // Geçerli dil kodu
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).scnDT,style: const TextStyle(color: Colors.white),),
        backgroundColor: Colors.indigo.shade900,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: S.of(context).scnDTS,
                prefixIcon: Icon(Icons.search, color: Colors.indigo.shade900),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.indigo.shade900),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.indigo.shade900),
                ),
              ),
              onChanged: (query) => _filterTables(query),
            ),
          ),
          Expanded(
            child: isLoading == true ? const Center(child: CircularProgressIndicator(),): ListView.builder(
              itemCount: _filteredTables.length,
              itemBuilder: (context, index) {
                final table = _filteredTables[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text('${S.of(context).scnDTN}: ${table['no']}'),
                    subtitle: Text('${S.of(context).scnDPPS}: ${locale == 'tr' ? table['status'] : (locale == 'en' ? (table['status'] == 'Dolu' ? 'Full' : 'Empty') : (table['status'] == 'Dolu' ? 'ممتلئ' : 'فارغ') )}',style: TextStyle(color: table['status'] == 'Dolu' ? Colors.red:Colors.green),),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: table['status'] == 'Dolu' ? Colors.grey : Colors.indigo.shade900),
                          onPressed: table['status'] == 'Dolu' ? null : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => UpdateTablePage(
                                  id: table['id'],
                                  no: table['no'],
                                ),
                              ),
                            ).then((_){ _fetchTables();});
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: table['status'] == 'Dolu' ? Colors.grey : Colors.red),
                          onPressed: table['status'] == 'Dolu' ? null : () {
                            _deleteTable(table['id']);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddNewTablePage())).then((_){_fetchTables();});
        },
        backgroundColor: Colors.indigo.shade900,
        child: const Icon(Icons.add,color: Colors.white,),
      ),
    );
  }
}
