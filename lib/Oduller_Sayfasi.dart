import 'package:flutter/material.dart';

class RozetlerSayfasi extends StatefulWidget {
  const RozetlerSayfasi({super.key});

  @override
  _RozetlerSayfasiState createState() => _RozetlerSayfasiState();
}

class _RozetlerSayfasiState extends State<RozetlerSayfasi> {
  // Filtreleme seçenekleri
  String _selectedFilter = 'Tüm Rozetler';

  // Örnek rozet verisi
  List<Rozet> rozetler = [
    Rozet(name: 'Rozet 1', progress: 0.5, imagePath: 'assets/rozet1.png'), // %50 tamamlanmış
    Rozet(name: 'Rozet 2', progress: 1.0, imagePath: 'assets/rozet2.png'), // %100 tamamlanmış
    Rozet(name: 'Rozet 3', progress: 0.2, imagePath: 'assets/rozet3.png'), // %20 tamamlanmış
    Rozet(name: 'Rozet 4', progress: 0.8, imagePath: 'assets/rozet4.png'), // %80 tamamlanmış
    Rozet(name: 'Rozet 5', progress: 1.0, imagePath: 'assets/rozet5.png'), // %70 tamamlanmış
    Rozet(name: 'Rozet 6', progress: 0.6, imagePath: 'assets/rozet6.png'), // %60 tamamlanmış
    Rozet(name: 'Rozet 7', progress: 0.6, imagePath: 'assets/rozet7.png'), // %60 tamamlanmış
  ];

  @override
  Widget build(BuildContext context) {
    // Filtreleme işlemi
    List<Rozet> filteredRozetler = rozetler;
    if (_selectedFilter == 'Kazanılan') {
      filteredRozetler = rozetler.where((rozet) => rozet.progress == 1.0).toList();
    } else if (_selectedFilter == 'Kazanılmayan') {
      filteredRozetler = rozetler.where((rozet) => rozet.progress < 1.0).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Rozetler Sayfası'),
      ),
      body: Column(
        children: [
          // Filtreleme Butonları
          // Filtreleme Butonları
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,  // Yatay kaydırma ekler
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _filterButton('Tüm Rozetler'),
                  SizedBox(width: 10), // Butonlar arasına boşluk ekler
                  _filterButton('Kazanılan'),
                  SizedBox(width: 10),
                  _filterButton('Kazanılmayan'),
                ],
              ),
            ),
          ),


          // SingleChildScrollView ile kaydırılabilir içerik
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  shrinkWrap: true, // İçeriğe göre boyutlanmasını sağlar
                  physics: BouncingScrollPhysics(), // Kaydırılabilir yapar
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Her satırda 2 rozet
                    crossAxisSpacing: 10.0, // Yatay boşluk
                    mainAxisSpacing: 10.0, // Dikey boşluk
                    childAspectRatio: 1.0, // Kare oran
                  ),
                  itemCount: filteredRozetler.length,
                  itemBuilder: (context, index) {
                    final rozet = filteredRozetler[index];
                    return _buildRozetCard(rozet);
                  },
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  // Filtreleme butonları için yardımcı fonksiyon
  Widget _filterButton(String filter) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedFilter == filter ? Colors.deepOrange : Colors.amber, // Seçili buton mavi, diğerleri gri
        foregroundColor: _selectedFilter == filter ? Colors.white : Colors.black, // Yazı rengi
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Buton iç boşluğu
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Köşeleri yuvarlatma
        ),
      ),
      child: Text(filter, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
    );
  }


  // Rozet kartlarını oluşturma
  Widget _buildRozetCard(Rozet rozet) {
    return Card(
      margin: EdgeInsets.all(8),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(45),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Rozet Resmi
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                rozet.imagePath,
                width: 70, // Resim genişliği
                height: 70, // Resim yüksekliği
                fit: BoxFit.cover, // Resmin düzgün şekilde kesilmesini sağlar
              ),
            ),
            SizedBox(height: 8),
            // Rozet adı
            Text(rozet.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            // İlerleme çubuğu
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 6,
                  color: Colors.grey[300],
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.4 * rozet.progress,
                  height: 6,
                  color: Colors.blue,
                ),
              ],
            ),
            SizedBox(height: 5),
            Text('${(rozet.progress * 100).toInt()}%', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class Rozet {
  final String name;
  final double progress; // 0.0 - 1.0 arasında değer
  final String imagePath; // Resim yolu

  Rozet({required this.name, required this.progress, required this.imagePath});
}