import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ayarlar'),
      ),
      body: ListView(
        children: [
          // PROFİL KISMI (Yuvarlak Fotoğraf + İsim)
          Column(
            children: [
              SizedBox(height: 20),
              CircleAvatar(
                radius: 50, // Profil resminin boyutu
                backgroundImage: AssetImage('assets/profile.jpg'),
                backgroundColor: Colors.grey[300], // Resim yoksa arkaplan
              ),
              SizedBox(height: 10),
              Text(
                'Kullanıcı Adı',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                'mail.adresi@gmail.com',
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
            onTap: () {
              // Profil düzenleme ekranına yönlendirilebilir
            },
          ),
          SwitchListTile(
            title: Text('Koyu Mod'),
            subtitle: Text('Tema değiştirmek için aç/kapat'),
            value: isDarkMode,
            onChanged: (value) {
              setState(() {
                isDarkMode = value;
              });
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
            onTap: () {
              // Şifre değiştirme ekranına yönlendirilebilir
            },
          ),
        ],
      ),
    );
  }
}