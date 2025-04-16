import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_coma/Screens/Chief/OrdersScreen.dart';
import 'package:my_coma/Screens/Cashier/CashierTablesScreen.dart';
import 'package:my_coma/Screens/Waiter/TablesScreen.dart';
import 'package:http/http.dart' as http;
import 'package:my_coma/generated/l10n.dart';
import 'package:my_coma/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_coma/Models/API.dart';
import 'package:my_coma/Screens/Manager/ManagerMainScreen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String errorMessage = '';
  bool isButtonEnabled = false;

  String _currentLanguage = 'en'; // Varsayılan dil

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
    _loadLanguagePreference();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadLanguagePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedLanguage = prefs.getString('language') ?? 'en';
    setState(() {
      _currentLanguage = savedLanguage;
      S.load(Locale(_currentLanguage));
    });
  }

  Future<void> _changeLanguage(String languageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
    setState(() {
      _currentLanguage = languageCode;
      S.load(Locale(languageCode));
    });
    // Uygulamanın dil değişikliği sonrasında güncellenmesi 
    runApp(MyApp(languageCode));
  }

  Future<void> login(String username, String password) async {
    try {
      // API'ye istek gönder
      final response = await http.get(
        Uri.parse('${clsAPI.baseURL}/${clsAPI.LOGIN}/$username/$password'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        // Kullanıcı bilgilerini sakla
        SharedPreferences prefs = await SharedPreferences.getInstance(); //cerezler 
        await prefs.setInt('id', jsonResponse['id']);
        await prefs.setString('name', jsonResponse['name']);
        await prefs.setString('role', jsonResponse['role']);
        await prefs.setString('imagePath', jsonResponse['imagePath']);

        // Role'e göre yönlendirme yap
        if (jsonResponse['role'] == 'Waiter') {
          setState(() {
            errorMessage = '';
          });
          Navigator.push(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(builder: (context) => TablesScreen()),
          );
        } else if (jsonResponse['role'] == 'Chef') {
          Navigator.push(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(builder: (context) => OrdersScreen()),
          );
        } else if (jsonResponse['role'] == 'Cashier') {
          Navigator.push(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(builder: (context) => CashierTablesScreen()),
          );
        } else if (jsonResponse['role'] == 'Manager') {
          Navigator.push(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(builder: (context) => const ManagerMainScreen()),
          );
        }
      } else if (response.statusCode == 400) {
        setState(() {
          errorMessage = S.of(context).scnLE;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          errorMessage = S.of(context).scnLN;
        });
      } else {
        setState(() {
          errorMessage = S.of(context).scnLA;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = S.of(context).scnLC;
      });
    }
  }

  void _updateButtonState() {
    setState(() {
      isButtonEnabled = _usernameController.text.trim().isNotEmpty &&
          _passwordController.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arka plan resmi
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Sayfanın içerik kısmı
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Dil Seçimi
                  DropdownButton<String>(
                    value: _currentLanguage,

                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        _changeLanguage(newValue);
                      }
                    },
                    items: const [
                      DropdownMenuItem(
                        value: 'en',
                        child: Text('English',style: TextStyle(color: Colors.black,fontSize: 20),),
                      ),
                      DropdownMenuItem(
                        value: 'tr',
                        child: Text('Türkçe',style: TextStyle(color: Colors.black,fontSize: 20),),
                      ),
                      DropdownMenuItem(
                        value: 'ar',
                        child: Text('العربية',style: TextStyle(color: Colors.black,fontSize: 20),),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    S.of(context).scnLTitle,
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: S.of(context).scnLU,
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: S.of(context).scnLP,
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isButtonEnabled
                        ? () async {
                            String username = _usernameController.text;
                            String password = _passwordController.text;
                            await login(username, password);
                            _usernameController.text = "";
                            _passwordController.text = "";
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ), // Buton devre dışı bırakılır
                    child: Text(S.of(context).scnLTitle),
                  ),
                  if (errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
