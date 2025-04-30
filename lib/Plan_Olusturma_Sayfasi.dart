import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'Beslenme_Plani_Sayfasi.dart';
import 'Manuel_Plan_Olusturma_Sayfasi.dart';

class MealPlanHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Beslenme Planı')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Henüz bir beslenme planınız yok",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showPlanOptionsDialog(context);
              },
              child: Text("Beslenme Planı Oluştur"),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlanOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Beslenme Planı Oluşturma Seçenekleri"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Dialogu kapat
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MealPlanCreationPage()),
                  );
                },
                child: Text("Yapay Zeka ile Oluştur"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Dialogu kapat
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ManualPlanPage()),
                  );
                },
                child: Text("Kendiniz Oluşturun"),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Yeni sayfa
class MealPlanCreationPage extends StatefulWidget {
  @override
  _MealPlanCreationPageState createState() => _MealPlanCreationPageState();
}

class _MealPlanCreationPageState extends State<MealPlanCreationPage> {
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  /// Kullanıcıya sağlık verisi yüklemesi için modal pencere gösteren fonksiyon
  void _showFileUploadDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Sağlık Verilerini Yükle"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Dosya yükleme işlemi burada yapılacak
                },
                child: Text("Dosya Yükle"),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Pencereyi kapat
                },
                child: Text("İptal"),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Plan başarıyla oluşturuldu mesajını gösteren popup
  void _showPlanCreatedDialog() async {
    // Kullanıcının girdiği verileri al
    String height = heightController.text;
    String weight = weightController.text;

    // Gün ve tarif eşleşmesi
    Map<DateTime, List<String>> dailyRecipes = {
      DateTime(2025, 4, 20): ['Omlet'],
      DateTime(2025, 4, 22): ['Karnıbahar'],
    };

    // Firestore'a ekleme işlemi
    try {
      // Önceki aktif planları pasif hale getir
      var previousPlans = await FirebaseFirestore.instance
          .collection('beslenme_planlari')
          .where('aktif', isEqualTo: true)
          .get();

      for (var doc in previousPlans.docs) {
        await doc.reference.update({'aktif': false}); // Eski planları pasif yap
      }

      print("Yeni beslenme planı ekleniyor...");
      // Firestore'da beslenme planı koleksiyonuna yeni bir plan ekle
      DocumentReference mealPlanRef = await FirebaseFirestore.instance.collection('beslenme_planlari').add({
        'height': height,
        'weight': weight,
        'created_at': FieldValue.serverTimestamp(), // Firestore'un sunucu zamanını ekler
        'aktif': true, // Yeni plan aktif olarak kaydediliyor
      });
      print("Beslenme planı eklendi: ${mealPlanRef.id}");

      // Kahvaltı, öğle yemeği, akşam yemeği ve ara öğünler için belgeler oluştur
      List<String> mealTypes = ['Kahvaltı', 'Öğle Yemeği', 'Akşam Yemeği', 'Ara Öğünler'];

      // **Belirtilen tüm günler için plan oluştur**
      for (DateTime day in dailyRecipes.keys) {
        String isoDate = DateFormat('yyyy-MM-dd').format(day); // Gün formatı: YYYY-MM-DD
        CollectionReference dailyPlanRef = mealPlanRef.collection(isoDate); // Her gün için koleksiyon oluştur
        print("Alt koleksiyon oluşturuldu: $isoDate");

        for (String mealType in mealTypes) {
          DocumentReference mealRef = dailyPlanRef.doc(mealType);
          await mealRef.set({
            'meal_type': mealType,
            'created_at': FieldValue.serverTimestamp(),
          });
          print("Öğün eklendi: $mealType - $isoDate");

          // Seçilen tarifleri ilgili öğüne ekle
          for (String recipeName in dailyRecipes[day] ?? []) {
            print("Tarif aranıyor: $recipeName");

            DocumentSnapshot recipeSnapshot = await FirebaseFirestore.instance
                .collection('tarifler')
                .doc(recipeName)
                .get();

            if (recipeSnapshot.exists) {
              print("Tarif bulundu: $recipeName");

              String recipeMealType = recipeSnapshot['meal_type'];
              print("Tarif meal_type: $recipeMealType");

              if (mealTypes.contains(recipeMealType)) {
                DocumentReference correctMealRef = dailyPlanRef.doc(recipeMealType);
                await correctMealRef.collection('tarifler').doc(recipeName).set(recipeSnapshot.data() as Map<String, dynamic>);
                print("Tarif eklendi: $recipeName -> $recipeMealType ($isoDate)");
              } else {
                print('Geçersiz meal_type: $recipeMealType');
              }
            } else {
              print("Tarif bulunamadı: $recipeName");
            }
          }
        }
      }
      print("Tüm günler için beslenme planı tamamlandı.");

      // Başarı mesajı göster
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Başarılı"),
            content: Text("Beslenme planı oluşturuldu"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Popup'ı kapat
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MealPlanPage()), // MealPlanPage'i aç
                  );
                },
                child: Text("Tamam"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Hata durumunda mesaj göster
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Hata"),
            content: Text("Beslenme planı oluşturulurken bir hata oluştu $e"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Tamam"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Beslenme Planı Oluştur")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Sağlık Verilerinizi Girin", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),

            // Kullanıcının boyunu girdiği alan
            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Boy (cm)"),
            ),

            // Kullanıcının kilosunu girdiği alan
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Kilo (kg)"),
            ),

            // TODO: Buraya bilimsel anlamda analiz edilmesi gereken diğer sağlık verilerini ekleyebilirsin.

            SizedBox(height: 20),

            // Plan oluşturma butonu
            ElevatedButton(
              onPressed:
              // TODO: Burada yapay zekaya çağrıları oluşturacağız.
              _showPlanCreatedDialog,
              child: Text("Planı Oluştur"),
            ),

            SizedBox(height: 10),

            // Sağlık verilerini otomatik girme butonu
            ElevatedButton(
              onPressed: _showFileUploadDialog,
              child: Text("Sağlık Verilerini Otomatik Gir"),
            ),
          ],
        ),
      ),
    );
  }
}