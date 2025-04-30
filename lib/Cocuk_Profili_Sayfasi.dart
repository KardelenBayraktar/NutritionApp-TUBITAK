import 'package:flutter/material.dart';

import 'Cocuk_Profil_Olusturma_Sayfasi.dart';

class CocukProfilSayfasi extends StatefulWidget {
  @override
  _CocukProfilSayfasiState createState() => _CocukProfilSayfasiState();
}

class _CocukProfilSayfasiState extends State<CocukProfilSayfasi> {
  bool cocukProfiliVar = false; // Şimdilik sabit; ileride Firestore'dan çekilecek

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Çocuk Profili'),
        centerTitle: true,
      ),
      body: Center(
        child: cocukProfiliVar
            ? Text("Çocuk profili mevcut (gelecekte buraya detaylar gelecek)")
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Henüz çocuk profili oluşturmadınız!",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CocukProfilOlusturmaSayfasi(),
                  ),
                );
              },
              child: Text("Çocuk Profili Oluştur"),
            ),
          ],
        ),
      ),
    );
  }
}