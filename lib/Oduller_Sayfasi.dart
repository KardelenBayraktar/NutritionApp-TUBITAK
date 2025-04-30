import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RozetlerSayfasi extends StatefulWidget {
  @override
  _RozetlerSayfasiState createState() => _RozetlerSayfasiState();
}

class _RozetlerSayfasiState extends State<RozetlerSayfasi> {
  String _selectedFilter = 'Tümü'; // Başlangıç filtresi
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _checkAndInitializeKazanilmayanRozetler();
  }

  // Kazanılmayan rozetleri kontrol et ve gerekirse başlat
  Future<void> _checkAndInitializeKazanilmayanRozetler() async {
    CollectionReference kazanilmayanRef = _firestore.collection('Rozetler').doc('Kazanılmayan').collection('RozetListesi');
    QuerySnapshot snapshot = await kazanilmayanRef.get();
    if (snapshot.docs.isEmpty) {
      var tumRozetlerRef = _firestore.collection('Rozetler').doc('Tümü').collection('RozetListesi');
      var tumRozetlerSnapshot = await tumRozetlerRef.get();
      for (var doc in tumRozetlerSnapshot.docs) {
        await kazanilmayanRef.doc(doc.id).set({'progress': 0.0});
      }
    }
  }

  // Seçilen filtreye göre Firestore'dan rozetleri çek
  Future<List<Map<String, dynamic>>> getRozetAltKoleksiyonlari(String filter) async {
    List<Map<String, dynamic>> rozetler = [];
    try {
      var snapshot = await _firestore.collection('Rozetler').doc(filter).collection('RozetListesi').get();
      for (var doc in snapshot.docs) {
        rozetler.add({
          'id': doc.id,
          'name': doc['name'], // name alanını alıyoruz
          'progress': doc['progress'],
        });
      }
      print("Başarıyla çekilen rozetler ($filter): $rozetler");
    } catch (e) {
      print("Rozetleri çekerken hata oluştu: $e");
    }
    return rozetler;
  }

  // Bir rozet kazanıldığında, kazanılmayan rozetlerden kazanılana taşı
  Future<void> rozetKazandin(String rozetId) async {
    try {
      var kazanilanRef = _firestore.collection('Rozetler').doc('Kazanılan').collection('RozetListesi').doc(rozetId);
      var kazanilmayanRef = _firestore.collection('Rozetler').doc('Kazanılmayan').collection('RozetListesi').doc(rozetId);

      // Kazanılmayan koleksiyonundaki belgeyi al
      var rozetData = await kazanilmayanRef.get();

      // Eğer belge varsa, Kazanılan koleksiyonuna taşı
      if (rozetData.exists) {
        // Kazanılan koleksiyonuna ekle
        await kazanilanRef.set(rozetData.data()!);

        // Kazanılmayan koleksiyonundan sil
        await kazanilmayanRef.delete();

        print('Rozet başarıyla kazanıldı ve taşındı.');
      }
    } catch (e) {
      print("Rozet kazanılırken hata oluştu: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rozetler Sayfası')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _filterButton('Tümü'),
                _filterButton('Kazanılan'),
                _filterButton('Kazanılmayan'),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>( // Firestore verilerini al
              future: getRozetAltKoleksiyonlari(_selectedFilter),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                var rozetler = snapshot.data!;
                if (rozetler.isEmpty) {
                  return Center(child: Text('Bu kategoride rozet bulunmamaktadır.'));
                }
                return ListView.builder(
                  itemCount: rozetler.length,
                  itemBuilder: (context, index) {
                    final rozetAdi = rozetler[index]['name']; // name alanını alıyoruz
                    final rozetId = rozetler[index]['id']; // rozetin id'sini alıyoruz

                    return Card(
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(rozetAdi), // Name'i ekrana yazdırıyoruz
                        trailing: _selectedFilter == 'Kazanılmayan'
                            ? IconButton(
                          icon: Icon(Icons.check),
                          onPressed: () {
                            rozetKazandin(rozetId); // Kazanma işlemi
                          },
                        )
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterButton(String filter) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedFilter == filter ? Colors.green : Colors.blue,
      ),
      child: Text(filter, style: TextStyle(color: Colors.white)),
    );
  }
}