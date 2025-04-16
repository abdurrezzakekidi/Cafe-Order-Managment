import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_coma/Models/API.dart';
import 'package:my_coma/Screens/Manager/Users/AddNewUser.dart';
import 'package:my_coma/Screens/Manager/Users/UpdateUserPage.dart';
import 'package:my_coma/generated/l10n.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List _users = [];
  List _filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = false;
  
  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    _fetchUsers();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchUsers() async {
    final response = await http.get(Uri.parse('${clsAPI.baseURL}/${clsAPI.USERS}'));

    if (response.statusCode == 200) {
      setState(() {
        _users = json.decode(response.body);
        _filteredUsers = _users;
      });
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        // ignore: use_build_context_synchronously
        SnackBar(content: Text(S.of(context).scnDUE),backgroundColor: Colors.red,),
      );
    }
  }

  void _filterUsers(String query) {
    final filtered = _users.where((user) {
      final userName = user['name'].toLowerCase();
      final input = query.toLowerCase();
      return userName.contains(input);
    }).toList();

    setState(() {
      _filteredUsers = filtered;
    });
  }

  Future<void> _deleteUser(int id) async {
    final response = await http.delete(Uri.parse('${clsAPI.baseURL}/${clsAPI.USER}/$id'));

    if (response.statusCode == 200) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        // ignore: use_build_context_synchronously
        SnackBar(content: Text(S.of(context).scnDUD),backgroundColor: Colors.green,),
      );
      _fetchUsers(); // Sayfanın yenilenmesi için kullanıcıları tekrar getiriyoruz
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        // ignore: use_build_context_synchronously
        SnackBar(content: Text(S.of(context).scnDUF),backgroundColor: Colors.red,),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    final locale = Localizations.localeOf(context).languageCode; // Geçerli dil kodu

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).scnDU,style: const TextStyle(color: Colors.white),),
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
                hintText: S.of(context).scnDUS,
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
              onChanged: (query) => _filterUsers(query),
            ),
          ),
          Expanded(
            child: isLoading == true ? Center(child: CircularProgressIndicator(),):  ListView.builder(
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(user['role'] == 'Manager' ? '${user['name']} (${S.of(context).scnDUY})' : user['name'],),
                    subtitle: Text(locale == 'en' ? user['role'] : (locale == 'tr' ? (user['role'] == 'Waiter' ? 'Garson' : (user['role'] == 'Chef' ? 'Şef' : (user['role'] == 'Manager' ? 'Yönetici' : 'Kasiyer'))) : (user['role'] == 'Waiter' ? 'النادل' : (user['role'] == 'Chef' ? 'شيف' : (user['role'] == 'Manager' ? 'مدير' : 'أمين صندوق'))))),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.indigo.shade900),
                          onPressed: () {
                            Navigator.of(context).push( MaterialPageRoute( builder: (context) => 
                            UpdateUserPage( id: user['id'], 
                                            name: user['name'],
                                            role: user['role'], 
                                            password: user['password'],
                                          ),),).then((_) { _fetchUsers();});
                          },
                        ),
                        IconButton(
                          icon: user['role'] == 'Manager' ? const Icon(Icons.delete, color: Colors.grey) : const Icon(Icons.delete, color: Colors.red),
                          onPressed: user['role'] != 'Manager' ? () {
                            _deleteUser(user['id']);
                          }: null,
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
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddUserPage())).then((_) {
          _fetchUsers();
        });     
        },
        backgroundColor: Colors.indigo.shade900,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
