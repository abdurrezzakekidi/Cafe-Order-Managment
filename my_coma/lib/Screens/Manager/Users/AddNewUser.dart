import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_coma/Models/API.dart';
import 'package:my_coma/generated/l10n.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedRole = 'Waiter';

  Future<void> _addUser() async {
    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse('${clsAPI.baseURL}/${clsAPI.USER}'),
        headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
        body: jsonEncode(<String, dynamic>{
          'id':0,
          'name': _nameController.text.trim(),
          'password': _passwordController.text.trim(),
          'role': _selectedRole,
          'imagePath':'',
        }),
      );
      
      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          // ignore: use_build_context_synchronously
          SnackBar(content: Text(S.of(context).scnDUAS),backgroundColor: Colors.green,),
        );
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          // ignore: use_build_context_synchronously
          SnackBar(content: Text(S.of(context).scnDUAF),backgroundColor: Colors.red,),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    final locale = Localizations.localeOf(context).languageCode; // Geçerli dil kodu

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).scnDUA,style: const TextStyle(color: Colors.white),),
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
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: S.of(context).scnLP,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return S.of(context).scnDUEPE;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                items: ['Waiter', 'Chef', 'Cashier'].map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(locale == 'en' ? role : (locale == 'tr' ? (role == 'Waiter' ? 'Garson' : (role == 'Chef' ? 'Şef' : 'Kasiyer')) : (role == 'Waiter' ? 'النادل' : (role == 'Chef' ? 'شيف' : 'أمين صندوق')))),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: S.of(context).scnDUR,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _addUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(S.of(context).scnDUA,style: const TextStyle(color: Colors.white),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
