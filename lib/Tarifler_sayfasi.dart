import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'Bir_tarif_sayfasi.dart';

class RecipeListPage extends StatefulWidget {
  @override
  _RecipeListPageState createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  String selectedFilter = 'Tümü'; // Seçili filtre
  String searchQuery = ''; // Arama çubuğu

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tarifler')),
      body: Column(
        children: [
          // Arama Çubuğu
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Tarif Ara...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),

          // Filtreleme Butonları
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ['Tümü', 'Kahvaltı', 'Öğle Yemeği', 'Ara Öğünler', 'Akşam Yemeği'].map((category) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: selectedFilter == category,
                    onSelected: (selected) {
                      setState(() {
                        selectedFilter = category;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          SizedBox(height: 10),

          // Tarifler Listesi
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('tarifler').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                var recipes = snapshot.data!.docs.where((doc) {
                  bool matchesCategory = selectedFilter == 'Tümü' || doc['meal_type'] == selectedFilter;
                  bool matchesSearch = doc['name'].toLowerCase().contains(searchQuery.toLowerCase());
                  return matchesCategory && matchesSearch;
                }).toList();

                return ListView(
                  children: recipes.map((doc) {
                    return _buildRecipeCard(doc);
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

// Tarif Kartı Widget'ı
  Widget _buildRecipeCard(QueryDocumentSnapshot recipe) {
    Map<String, dynamic> recipeData = recipe.data() as Map<String, dynamic>; // Belge verisini Map olarak al

    String imageUrl = (recipeData.containsKey('image') && recipeData['image'].isNotEmpty)
        ? recipeData['image']
        : 'assets/emoji.jpg'; // Varsayılan resim URL'si

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      elevation: 3,
      child: ListTile(
        leading: SizedBox(
          width: 50, // Maksimum genişlik
          height: 50, // Maksimum yükseklik
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.network(
                  'https://pbs.twimg.com/amplify_video_thumb/1893346240101744642/img/emoji.jpg',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
        ),
        title: Text(recipeData['name'], style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(recipeData['meal_type']),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailPage(tarifAdi: recipe.id),
            ),
          );
        },
      ),
    );
  }
}