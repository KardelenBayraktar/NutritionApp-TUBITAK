import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final Function(bool) onThemeChanged;

  SettingsPage({required this.onThemeChanged});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;
  bool notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences(); // 📌 Uygulama açıldığında koyu mod ayarını yükle
  }

  void _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('darkMode') ?? false; // 🔥 Kaydedilmiş değeri yükle
    });
  }

  void _savePreferences(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ayarlar'),
      ),
      body: ListView(
        children: [
          Column(
            children: [
              SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/profile.jpg'),
                backgroundColor: Colors.grey[300],
              ),
              SizedBox(height: 10),
              Text(
                'Emirhan Aky',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                'emirhan8akyildirim@gmail.com',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 20),
            ],
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profil Bilgileri'),
            subtitle: Text('Profil bilgilerinizi düzenleyin'),
            onTap: () {},
          ),
          SwitchListTile(
            title: Text('Koyu Mod'),
            subtitle: Text('Tema değiştirmek için aç/kapat'),
            value: isDarkMode,
            onChanged: (value) {
              setState(() {
                isDarkMode = value;
              });
              _savePreferences(value); // 🔥 Değişikliği kaydet
              widget.onThemeChanged(value);
            },
            secondary: Icon(Icons.dark_mode),
          ),
          SwitchListTile(
            title: Text('Bildirimleri Al'),
            subtitle: Text('Uygulama bildirimlerini aç/kapat'),
            value: notificationsEnabled,
            onChanged: (value) {
              setState(() {
                notificationsEnabled = value;
              });
            },
            secondary: Icon(Icons.notifications),
          ),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text('Şifreyi Değiştir'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
