import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_coma/Models/API.dart';
import 'package:my_coma/Screens/Manager/Products/AddNewProductPage.dart';
import 'package:my_coma/Screens/Manager/Products/UpdateProductPage.dart';
import 'package:my_coma/Models/clsProduct.dart';
import 'package:my_coma/generated/l10n.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    _fetchProducts();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchProducts() async {
    final response = await http.get(Uri.parse('${clsAPI.baseURL}/${clsAPI.PRODUCTS}'));

    if (response.statusCode == 200) {
      setState(() {
        List jsonResponse = json.decode(response.body);
        _products = jsonResponse.map((data) => Product.fromJson(data)).toList();
        _filteredProducts = _products;
      });
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).scnDPE),backgroundColor: Colors.red,),
      );
    }
  }

  void _filterProducts(String query) {
    final filtered = _products.where((product) {
      final productName = product.name.toLowerCase();
      final input = query.toLowerCase();
      return productName.contains(input);
    }).toList();

    setState(() {
      _filteredProducts = filtered;
    });
  }

  Future<void> _deleteProduct(int id) async {
    final response = await http.delete(Uri.parse('${clsAPI.baseURL}/${clsAPI.PRODUCT}/$id'));

    if (response.statusCode == 200) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        // ignore: use_build_context_synchronously
        SnackBar(content: Text(S.of(context).scnDUD),backgroundColor: Colors.green,),
      );
      _fetchProducts(); // Sayfanın yenilenmesi için ürünleri tekrar getiriyoruz
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
        title: Text(S.of(context).scnDP,style: const TextStyle(color: Colors.white),),
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
                hintText: S.of(context).scnDPS,
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
              onChanged: (query) => _filterProducts(query),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: isLoading == true ? const Center(child: CircularProgressIndicator(),): ListTile(
                    title: Text(product.name),
                    subtitle: Text('${S.of(context).scnDPP}: ${product.price} ₺ | ${S.of(context).scnDPPS}: ${locale == 'tr' ? product.status : (locale == 'en' ? (product.status == 'Var' ? 'Available' : 'Unavailable'):(product.status == 'Var' ? 'متاح' : 'غير متاح'))}',style:TextStyle(color: product.status == 'Yok' ? Colors.red:Colors.green),),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.indigo.shade900),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => UpdateProductPage(
                                  id: product.id,
                                  name: product.name,
                                  price: product.price,
                                  status: product.status,
                                ),
                              ),
                            ).then((_){_fetchProducts();});
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deleteProduct(product.id);
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
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddNewProductPage())).then((_){_fetchProducts();});
        },
        backgroundColor: Colors.indigo.shade900,
        child: const Icon(Icons.add,color: Colors.white,),
      ),
    );
  }
}
