import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_coma/Models/API.dart';
import 'package:http/http.dart' as http;
import 'package:my_coma/Models/clsTableOrders.dart';
import 'package:my_coma/generated/l10n.dart';

class TableOrdersScreen extends StatefulWidget {
  final int tableId;
  const TableOrdersScreen({super.key, required this.tableId});

  @override
  State<TableOrdersScreen> createState() => _TableOrdersScreenState();
}

class _TableOrdersScreenState extends State<TableOrdersScreen> {
  List<clsTableOrders> orders = [];
  bool hasOrders = false;
  String errorMessage = '';
  bool isLoading = false;
  bool enabledButton = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
    });
    await fetchOrders();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchOrders() async {
    final response = await http.get(Uri.parse('${clsAPI.baseURL}/${clsAPI.ALL_TABLE_ORDERS}/${widget.tableId}'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      if (jsonResponse.isNotEmpty) {
        setState(() {
          hasOrders = true;
          enabledButton = true;
          orders = jsonResponse.map((data) => clsTableOrders.fromJson(data)).toList();
        });
      }
    } else if (response.statusCode == 404) {
      setState(() {
        hasOrders = false;
        orders = [];
        errorMessage = S.of(context).scnNTO;
      });
    } else {
      setState(() {
        errorMessage = S.of(context).scnDPE;
      });
    }
  }

  Future<void> pay(BuildContext context, int tableId) async {
    final response = await http.post(
      Uri.parse('${clsAPI.baseURL}/${clsAPI.PAY}/$tableId'),
    );

    if (response.statusCode == 200) {
      setState(() {
        enabledButton = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(S.of(context).scnTGPS),
        backgroundColor: Colors.green,
      ));
      await fetchOrders();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(S.of(context).scnTGPF),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).scnTO, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueGrey,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.sentiment_dissatisfied, size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        S.of(context).scnTOF,
                        style: const TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 4,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                            leading: const Icon(Icons.fastfood, color: Colors.blueGrey, size: 40),
                            title: Text(
                              order.name,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${S.of(context).scnDPP}: ${order.price} ₺',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      left: Directionality.of(context) == TextDirection.rtl ? null : 16,
                      right: Directionality.of(context) == TextDirection.rtl ? 16 : null,
                      bottom: 16,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '${S.of(context).scnTTA}: ${orders.fold(0.0, (sum, order) => sum + order.price).toStringAsFixed(2)} ₺',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: enabledButton ? () => pay(context, widget.tableId) : null,
        label: Text(S.of(context).scnTGP, style: const TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.payment),
        backgroundColor: Colors.blueGrey,
      ),
    );
  }
}
