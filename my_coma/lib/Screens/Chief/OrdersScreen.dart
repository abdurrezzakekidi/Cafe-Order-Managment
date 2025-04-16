import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_coma/Models/API.dart';
import '../../Models/clsOrders.dart';
import 'package:my_coma/generated/l10n.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<clsOrders> orders = [];
  bool isLoading = false; // Yüklenme durumu
  bool hasOrders = false; // Sipariş olup olmadığını kontrol eder
  String message = "";
  @override
  void initState() {
    super.initState();
    loadData(); // Siparişleri API'dan çeken fonksiyon
  }

  // Yükleme işlemi ve API'den veri çekme
  Future<void> loadData() async {
    setState(() {
      isLoading = true; // Yükleme başlıyor
    });
    await fetchOrders(); // Siparişleri yükle
    setState(() {
      isLoading = false; // Yükleme bitti
    });
  }

  // API'dan siparişleri çekme
  Future<void> fetchOrders() async {
    try {
      final response = await http.get(Uri.parse('${clsAPI.baseURL}/${clsAPI.ALL_ORDERS}'));

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        setState(() {
          orders = jsonResponse.map((data) => clsOrders.fromJson(data)).toList();
          hasOrders = orders.isNotEmpty; 
        });
      }else if(response.statusCode == 404)
      {
        setState(() {
          orders = [];
          hasOrders = false; 
          message = S.of(context).scnO.toString();
        });
      } 
      else {
        setState(() {
          hasOrders = false; 
          message = S.of(context).scnOF;
        });
      }
    } catch (error) {
      setState(() {
        hasOrders = false; 
      });
    } finally {
      setState(() {
        isLoading = false; 
      });
    }
  }

  // Siparişin durumunu güncelleyen fonksiyon
  Future<void> updateOrderStatus(int orderId, String status) async {
    final response = await http.put(
      Uri.parse('${clsAPI.baseURL}/${clsAPI.UPDATE_STATUS}/$orderId/$status'),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).scnOD),backgroundColor: Colors.green),
      );
      await loadData(); // Durum güncellenince siparişleri tekrar yükle
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).scnOND),backgroundColor: Colors.red,),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
    title: Text(S.of(context).scnCO),
    actions: [
      IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: () async {
          // Buraya fonksiyonu çağırın
          await loadData(); // Bu, belirtmek istediğiniz fonksiyon
        },
      ),
    ],
  ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Yükleniyor göstergesi
          : hasOrders
              ? ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        leading: Icon(Icons.local_dining, size: 40, color: Colors.orange),
                        title: Text(
                          '${S.of(context).scnDTN}: ${orders[index].tableNo} - ${S.of(context).scnP}: ${orders[index].orderName}',
                          style: TextStyle(fontSize: 18),
                        ),
                        trailing: orders[index].orderStatus == "Siparis Edildi"
                            ? IconButton(
                                icon: Icon(Icons.check_circle, color: Colors.green, size: 30),
                                onPressed: () {
                                  updateOrderStatus(orders[index].orderId, "Teslim Edildi");
                                },
                              )
                            : Icon(Icons.check_circle, color: Colors.grey), // Teslim edildiğinde gri göster
                      ),
                    );
                  },
                )
              : Center(child: Text(S.of(context).scnO, style: TextStyle(fontSize: 20))), // Sipariş yoksa mesaj göster
    );
  }
}


