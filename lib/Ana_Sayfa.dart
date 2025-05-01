import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = "Kullanıcı Adı"; // Kullanıcının adı (Firestore'dan çekilecek)
  String profileImageUrl = "assets/emoji.jpg"; // Profil resmi URL (Firestore'dan çekilecek)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // SideBar (Drawer)
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF86A788)), // Sidebar üst kısmı
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage(profileImageUrl), // Yerel resim için AssetImage kullanılır
                  ),
                  SizedBox(height: 8),
                  Text(
                    userName,
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(Icons.home, "Ana Sayfa", "/home"),
            _buildDrawerItem(Icons.event_note, "Planım", "/plan"),
            _buildDrawerItem(Icons.track_changes, "Gelişim Takibi", "/gelisim"),
            _buildDrawerItem(Icons.book, "Tarifler", "/recipes"),
            _buildDrawerItem(Icons.favorite, "Favorilerim", "/favorites"), // Yeni sekme eklendi
            _buildDrawerItem(Icons.support_agent, "Asistan", "/assistant"),
            _buildDrawerItem(Icons.star, "Rozetler", "/badges"),
            _buildDrawerItem(Icons.settings, "Ayarlar", "/settings"),
          ],
        ),
      ),

      // AppBar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black), // Menü butonu siyah
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              userName, // Kullanıcı Adı
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
            SizedBox(width: 12),

            // Profil Resmi (Buton)
            GestureDetector(
              onTap: () {
                // Profil sayfasına yönlendirme burada olacak
              },
              child: CircleAvatar(
                radius: 22,
                backgroundImage: AssetImage(profileImageUrl), // Yerel resim için AssetImage kullanılır
              ),
            ),
            SizedBox(width: 12),

            // Bildirim Butonu
            IconButton(
              onPressed: () {
                // Bildirimler sayfasına yönlendirme burada olacak
              },
              icon: Icon(Icons.notifications),
              color: Colors.black,
            ),
          ],
        ),
      ),

      // İçerik Bölümü
      body: Center(
        child: Text(
          "Ana Sayfa İçeriği",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  /// SideBar Menü Elemanı Oluşturma Fonksiyonu
  Widget _buildDrawerItem(IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFF86A788)),
      title: Text(title, style: TextStyle(fontSize: 16)),
      onTap: () {
        Navigator.pop(context); // Drawer'ı kapat
        Navigator.pushNamed(context, route); // Belirtilen sayfaya yönlendir
      },
    );
  }
}