import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'Bir_tarif_sayfasi.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favori Tarifler'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('favoriler').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> favoriteSnapshot) {
          if (favoriteSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!favoriteSnapshot.hasData || favoriteSnapshot.data!.docs.isEmpty) {
            return Center(child: Text('Henüz favorilere eklenen bir tarif yok.'));
          }

          final favoriteRecipeIds = favoriteSnapshot.data!.docs.map((doc) => doc.id).toList();

          return FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('recipes')
                .where(FieldPath.documentId, whereIn: favoriteRecipeIds)
                .get(),
            builder: (context, AsyncSnapshot<QuerySnapshot> recipeSnapshot) {
              if (recipeSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!recipeSnapshot.hasData || recipeSnapshot.data!.docs.isEmpty) {
                return Center(child: Text('Favori tarifler bulunamadı.'));
              }

              final favoriteRecipes = recipeSnapshot.data!.docs.map((doc) {
                return {
                  'id': doc.id,
                  'name': doc['name'] ?? '',
                  'meal_type': doc['meal_type'] ?? 'Bilinmeyen',
                  'imageUrl': doc['imageUrl'] ?? 'https://www.example.com/yemek.jpg',
                };
              }).toList();

              return Padding(
                padding: EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: favoriteRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = favoriteRecipes[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecipeDetailPage(recipeId: recipe['id']),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
                              child: Image.network(
                                recipe['imageUrl'],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      recipe['name'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      recipe['meal_type'], // Öğün türü gösteriliyor
                                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Icon(Icons.favorite, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}