import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'Favoriler_sayfasi.dart';

class RecipeDetailPage extends StatefulWidget {
  final String tarifAdi;
  RecipeDetailPage({required this.tarifAdi});

  @override
  _RecipeDetailPageState createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  bool isFavorite = false;
  Map<String, dynamic>? recipeData;

  @override
  void initState() {
    super.initState();
    _fetchRecipeDetails();
    _checkIfFavorite(); // Sayfa açıldığında favori olup olmadığını kontrol et
  }

  // Firestore'dan tarifin detaylarını çek
  void _fetchRecipeDetails() async {
    DocumentSnapshot recipeSnapshot = await FirebaseFirestore.instance
        .collection('tarifler')
        .doc(widget.tarifAdi)
        .get();

    if (recipeSnapshot.exists) {
      setState(() {
        recipeData = recipeSnapshot.data() as Map<String, dynamic>;
      });
    }
  }

  // Firestore'dan tarifin favorilere eklenip eklenmediğini kontrol et
  void _checkIfFavorite() async {
    DocumentSnapshot favoriteSnapshot = await FirebaseFirestore.instance
        .collection('favorites')
        .doc(widget.tarifAdi)
        .get();

    if (favoriteSnapshot.exists) {
      setState(() {
        isFavorite = true;
      });
    }
  }

  // Tarif favorilere ekleme/çıkarma işlemi
  void toggleFavorite() async {
    setState(() {
      isFavorite = !isFavorite;
    });

    if (isFavorite) {
      // Tarif favorilere ekleniyor
      await FirebaseFirestore.instance.collection('favorites').doc(widget.tarifAdi).set({
        'name': recipeData?['name'],
        'image': recipeData?['image'],
        'ingredients': recipeData?['ingredients'],
        'meal_type': recipeData?['meal_type'],
        'steps': recipeData?['steps'],
        'serving': recipeData?['serving'],
        'besinDeğerleri': recipeData?['besinDeğerleri'],
        'summary': recipeData?['summary'],
      });
      showSnackbar(true); // Favorilere eklendi mesajı göster
    } else {
      // Tarif favorilerden kaldırılıyor
      await FirebaseFirestore.instance.collection('favorites').doc(widget.tarifAdi).delete();
      showSnackbar(false);
    }
  }

  void showSnackbar(bool isAdded) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isAdded ? 'Tarif favorilere eklendi' : 'Tarif favorilerden kaldırıldı',
        ),
        action: SnackBarAction(
          label: 'Favorilere Git',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FavoritesPage()),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (recipeData == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Tarif Detayı')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Tarif Detayı')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: NetworkImage(recipeData!['image']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: toggleFavorite,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  recipeData!['name'],
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                _buildCard(title: 'Malzemeler', content: _buildList(recipeData!['ingredients'])),
                SizedBox(height: 16),
                _buildCard(title: 'Yapılış Aşamaları', content: _buildList(recipeData!['steps'])),
                SizedBox(height: 16),
                _buildCard(title: 'Servis & Porsiyon Bilgisi', content: Text(recipeData!['serving'])),
                SizedBox(height: 16),
                _buildCard(title: 'Besin Değerleri', content: _buildNutrition(recipeData!['besinDeğerleri'])),
                SizedBox(height: 16),
                _buildCard(title: 'Ekstra Bilgiler', content: Text(recipeData!['summary'])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required Widget content}) {
    return Container(
      width: MediaQuery.of(context).size.width - 32,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 3,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              content,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<dynamic> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(items.length, (index) => Text('- ${items[index]}')),
    );
  }

  Widget _buildNutrition(Map<String, dynamic> nutrition) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Kalori: ${nutrition['Kalori']}'),
        Text('Karbonhidrat: ${nutrition['Karbonhidrat']}'),
        Text('Protein: ${nutrition['Protein']}'),
        Text('Yağ: ${nutrition['Yağ']}'),
      ],
    );
  }
}