import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'Cocuk_Profil_Olusturma_Sayfasi.dart';

class CocukProfilSayfasi extends StatefulWidget {
  @override
  _CocukProfilSayfasiState createState() => _CocukProfilSayfasiState();
}

class _CocukProfilSayfasiState extends State<CocukProfilSayfasi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Çocuk Profili'),
        centerTitle: true,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('cocuklar').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
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
            );
          }

          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Yatayda en fazla 2 profil
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final isim = data['isim'] ?? 'İsim yok';
                      final profilResmiUrl = data['profilResmi'] ?? null;

                      return GestureDetector(
                        onTap: () {
                          // Burada profili tıklayınca olacak işlemler yapılacak
                        },
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: profilResmiUrl != null
                                  ? NetworkImage(profilResmiUrl)
                                  : AssetImage('assets/emoji.jpg')
                              as ImageProvider,
                            ),
                            SizedBox(height: 10),
                            Text(
                              isim,
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CocukProfilOlusturmaSayfasi(),
                      ),
                    );
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(Icons.add, color: Colors.white, size: 35),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}