import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_coma/Models/API.dart';
import 'package:flutter/services.dart';
import 'package:my_coma/generated/l10n.dart';

class AddNewTablePage extends StatefulWidget {
  const AddNewTablePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddNewTablePageState createState() => _AddNewTablePageState();
}

class _AddNewTablePageState extends State<AddNewTablePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _noController = TextEditingController();

  Future<void> _addTable() async {
    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse('${clsAPI.baseURL}/${clsAPI.TABLE}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'id': 0,
          'no': int.parse(_noController.text),
          'status': 'Bos', // Varsayılan olarak 'Bos'
        }),
      );

      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          // ignore: use_build_context_synchronously
          SnackBar(content: Text(S.of(context).scnDTAM),backgroundColor: Colors.green,),
        );
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          // ignore: use_build_context_synchronously
          SnackBar(content: Text(S.of(context).scnDTAF),backgroundColor: Colors.red,),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).scnDTA,style: const TextStyle(color: Colors.white),),
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
              controller: _noController,
              decoration: InputDecoration(
                labelText: S.of(context).scnDTN,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              keyboardType: TextInputType.number, // Sayı girilmesini sağlamak için
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // Sadece rakamların girilmesine izin verir
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return S.of(context).scnDTASM;
                }
                return null;
              },
            ),

              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _addTable,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(S.of(context).scnDTA,style: const TextStyle(color: Colors.white),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
