import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:my_coma/Screens/Manager/Products/ProductsPage.dart';
import 'package:my_coma/Screens/Manager/Reports/MonthReport.dart';
import 'package:my_coma/Screens/Manager/Reports/YearlyReport.dart';
import 'package:my_coma/Screens/Manager/Tables/TablesPage.dart';
import 'package:my_coma/Screens/Manager/Users/Users.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_coma/Screens/Manager/Reports/TodayReport.dart';
import 'package:my_coma/generated/l10n.dart';

class ManagerMainScreen extends StatefulWidget {
  const ManagerMainScreen({super.key});

  @override
  _ManagerMainScreenState createState() => _ManagerMainScreenState();
}

class _ManagerMainScreenState extends State<ManagerMainScreen> {
  late String selectedSection = S.of(context).scnDH;
  String managerName = ''; // Kullanıcı adını saklamak için bir değişken
  String imagePath = ''; 


  @override
  void initState() {
    super.initState();
    _loadManagerName(); // Adı yüklemek için fonksiyonu çağırıyoruz
  }

  Future<void> _loadManagerName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      managerName = prefs.getString('name') ?? 'Manager'; // Adı yükle ve varsayılan olarak 'Manager' ayarla
      imagePath = prefs.getString('imagePath') ?? '';
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      _updateImage(imageFile);
    }
  }

  Future<void> _updateImage(File imageFile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('id') ?? 0; // Varsayılan olarak 0 alır
    String oldImagePath = prefs.getString('imagePath') ?? '';

    // API'ye veri gönder
    var uri = Uri.parse('http://coma.somee.com/api/Users/UpdateImage');
    var request = http.MultipartRequest('PUT', uri)
      ..fields['Id'] = userId.toString()
      ..fields['OldImagePath'] = oldImagePath
      ..files.add(await http.MultipartFile.fromPath('NewImage', imageFile.path));

    var response = await request.send();
   
    if (response.statusCode == 200) {
      // API başarılı ise, dönen yanıtı işleyin
      final responseData = await http.Response.fromStream(response);
      final responseJson = json.decode(responseData.body);
      String newImageUrl = responseJson['imageName'];

      // Yeni resmi SharedPreferences'a kaydet
      prefs.setString('imagePath', newImageUrl);
      
      setState(() {
        imagePath = newImageUrl; // Yeni resim linkini güncelle
      });
    } else if(response.statusCode == 400) {
      ScaffoldMessenger.of(context).showSnackBar(
          // ignore: use_build_context_synchronously
          SnackBar(content: Text(S.of(context).scnLA),backgroundColor: Colors.red,),
        );
    }
    else if(response.statusCode == 500){
      ScaffoldMessenger.of(context).showSnackBar(
          // ignore: use_build_context_synchronously
          SnackBar(content: Text(S.of(context).scnLA),backgroundColor: Colors.red,),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedSection,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white,),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade900,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildHeader(context, managerName, imagePath),
              buildMenuItems(context),
            ],
          ),
        ),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          buildDashboardCard(Icons.today, S.of(context).scnDD, () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const TodayReportPage()));
          }),
          buildDashboardCard(Icons.list_alt, S.of(context).scnDP, () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ProductsPage()));
          }),
          buildDashboardCard(Icons.person_outline, S.of(context).scnDU, () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const UsersPage()));
          }),
          buildDashboardCard(Icons.table_chart, S.of(context).scnDT, () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const TablesPage()));
          }),
        ],
      ),
    );
  }

  Widget buildDashboardCard(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.indigo.shade900),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.indigo.shade900)),
          ],
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context, String userName, String userImage) => Container(
        color: Colors.indigo.shade900,
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickImage, // Avatar'a tıklanabilirlik ekleyin
              child: CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(userImage),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              userName[0].toUpperCase() + userName.substring(1).toLowerCase(),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      );

  Widget buildMenuItems(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        buildMenuItem(context, Icons.today, S.of(context).scnDD, () {
          Navigator.pop(context);
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const TodayReportPage()));
        }),
        buildMenuItem(context, Icons.calendar_today, S.of(context).scnDM, () {
          Navigator.pop(context);
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MonthlyReportPage()));
        }),
        buildMenuItem(context, Icons.calendar_today_outlined, S.of(context).scnDY, () {
          Navigator.pop(context);
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const YearlyReportPage()));
        }),
        buildDivider(),
        buildMenuItem(context, Icons.person_outline, S.of(context).scnDU, () {
          Navigator.pop(context);
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const UsersPage()));
        }),
        buildDivider(),
        buildMenuItem(context, Icons.list_alt, S.of(context).scnDP, () {
          Navigator.pop(context);
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ProductsPage()));
        }),
        buildDivider(),
        buildMenuItem(context, Icons.table_chart, S.of(context).scnDT, () {
          Navigator.pop(context);
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const TablesPage()));
        }),
      ],
    ),
  );

  Widget buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo.shade900),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w500, color: Colors.indigo.shade900),
      ),
      onTap: onTap,
    );
  }

  Widget buildDivider() => const Divider(
    color: Colors.black54,
  );
}
