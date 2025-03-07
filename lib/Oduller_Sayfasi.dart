import 'package:flutter/material.dart';

class RozetlerSayfasi extends StatefulWidget {
  @override
  _RozetlerSayfasiState createState() => _RozetlerSayfasiState();
}

class _RozetlerSayfasiState extends State<RozetlerSayfasi> {
  // Filtreleme seçenekleri
  String _selectedFilter = 'Tüm Rozetler';

  // Örnek rozet verisi
  List<Rozet> rozetler = [
    Rozet(name: 'Rozet 1', progress: 0.5), // %50 tamamlanmış
    Rozet(name: 'Rozet 2', progress: 1.0), // %100 tamamlanmış
    Rozet(name: 'Rozet 3', progress: 0.2), // %20 tamamlanmış
    Rozet(name: 'Rozet 4', progress: 0.8), // %80 tamamlanmış
  ];

  @override
  Widget build(BuildContext context) {
    // Filtreleme işlemi
    List<Rozet> filteredRozetler = rozetler;
    if (_selectedFilter == 'Kazanılan Rozetler') {
      filteredRozetler = rozetler.where((rozet) => rozet.progress == 1.0).toList();
    } else if (_selectedFilter == 'Kazanılmayan Rozetler') {
      filteredRozetler = rozetler.where((rozet) => rozet.progress < 1.0).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Rozetler Sayfası'),
      ),
      body: Column(
        children: [
          // Filtreleme Butonları
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _filterButton('Tüm Rozetler'),
                _filterButton('Kazanılan Rozetler'),
                _filterButton('Kazanılmayan Rozetler'),
              ],
            ),
          ),

          // Filtrelenmiş rozetler listesi
          Expanded(
            child: ListView.builder(
              itemCount: filteredRozetler.length,
              itemBuilder: (context, index) {
                final rozet = filteredRozetler[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(rozet.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dolum çubuğu
                        LinearProgressIndicator(
                          value: rozet.progress,
                          minHeight: 8,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                        SizedBox(height: 5),
                        Text('${(rozet.progress * 100).toInt()}% Tamamlandı'),
                      ],
                    ),
                  ),
                );
              },
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
      child: Text(filter),
    );
  }
}

class Rozet {
  final String name;
  final double progress; // 0.0 - 1.0 arasında değer

  Rozet({required this.name, required this.progress});
}