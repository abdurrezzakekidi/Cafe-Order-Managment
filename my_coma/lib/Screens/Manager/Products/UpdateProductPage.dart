import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_coma/Models/API.dart';
import 'package:flutter/services.dart';
import 'package:my_coma/generated/l10n.dart';

class UpdateProductPage extends StatefulWidget {
  final int id;
  final String name;
  final double price;
  final String status;

  const UpdateProductPage({super.key, required this.id, required this.name, required this.price, required this.status});

  @override
  // ignore: library_private_types_in_public_api
  _UpdateProductPageState createState() => _UpdateProductPageState();
}

class _UpdateProductPageState extends State<UpdateProductPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _priceController = TextEditingController(text: widget.price.toString());
    _selectedStatus = widget.status;
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      final response = await http.put(
        Uri.parse('${clsAPI.baseURL}/${clsAPI.PRODUCT}/${widget.id}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'id': widget.id,
          'name': _nameController.text,
          'price': double.parse(_priceController.text),
          'status': _selectedStatus,
        }),
      );

      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          // ignore: use_build_context_synchronously
          SnackBar(content: Text(S.of(context).scnDPUM),backgroundColor: Colors.green,),
        );
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          // ignore: use_build_context_synchronously
          SnackBar(content: Text(S.of(context).scnDPME),backgroundColor: Colors.red,),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    final locale = Localizations.localeOf(context).languageCode; // Geçerli dil kodu

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).scnDPU,style: const TextStyle(color: Colors.white),),
        backgroundColor: Colors.indigo.shade900,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: S.of(context).scnDPN,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return S.of(context).scnDUEE;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: S.of(context).scnDPP,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true), // Ondalıklı sayı girişi
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')), // Sadece rakam ve '.' izin ver
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return S.of(context).scnDUEPP;
                  }
                  final parsedValue = double.tryParse(value);
                  if (parsedValue == null) {
                    return S.of(context).scnDVN;
                  }
                  if (parsedValue <= 0) {
                    return S.of(context).scnDVNE;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                items: ['Var', 'Yok'].map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(locale == 'tr' ? status : (locale == 'en' ? (status == 'Var' ? 'Available' : 'Unavailable'):(status == 'Var' ? 'متاح' : 'غير متاح'))),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: S.of(context).scnDPPS,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _updateProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(S.of(context).scnDPU,style: const TextStyle(color: Colors.white),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}