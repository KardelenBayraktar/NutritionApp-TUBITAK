import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
                // Yeni sayfaya yönlendirme
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MealPlanCreationPage()),
                );
              },
              child: Text("Beslenme Planı Oluştur"),
            ),
          ],
        ),
      ),
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
    List<String> selectedRecipes = ['omlet', 'sucuklu_yumurta', 'tavuklu_pilav']; // Kullanıcının seçtiği tarif isimleri

    // Firestore'a ekleme işlemi
    try {
      // Firestore'da beslenme planı koleksiyonuna yeni bir plan ekle
      DocumentReference mealPlanRef = await FirebaseFirestore.instance.collection('beslenme_planlari').add({
        'height': height,
        'weight': weight,
        'created_at': FieldValue.serverTimestamp(), // Firestore'un sunucu zamanını ekler
      });
      // Beslenme planı için gün, ay, yıl formatında alt koleksiyon oluştur
      String isoDate = DateFormat('yyyy-MM-dd').format(DateTime(2025, 3, 4));
      CollectionReference dailyPlanRef = mealPlanRef.collection(isoDate); // Yıl-Ay-Gün formatında alt koleksiyon

      // Kahvaltı, öğle yemeği, akşam yemeği ve ara öğünler için belgeler oluştur
      List<String> mealTypes = ['kahvalti', 'ogle_yemegi', 'aksam_yemegi', 'ara_ogunler'];

      for (String mealType in mealTypes) {
        DocumentReference mealRef = dailyPlanRef.doc(mealType); // Önce referansı al
        await mealRef.set({ // Daha sonra belgeyi oluştur
          'meal_type': mealType,
          'created_at': FieldValue.serverTimestamp(),
        });

        // Seçilen tarifleri ilgili öğüne ekle
        for (String recipeName in selectedRecipes) {
          // Firestore'daki tarifler koleksiyonuna eriş
          DocumentSnapshot recipeSnapshot = await FirebaseFirestore.instance
              .collection('tarifler')
              .doc(recipeName) // Mevcut tarif adı ile belgeyi al
              .get();

          if (recipeSnapshot.exists) {
            // Tarifi Firestore'da bulduktan sonra meal_type alanını kontrol edelim
            String recipeMealType = recipeSnapshot['meal_type'];

            // Eğer meal_type uygun bir öğüne denk geliyorsa, doğru belgeye ekleyelim
            if (mealTypes.contains(recipeMealType)) {
              DocumentReference correctMealRef = dailyPlanRef.doc(recipeMealType);
              await correctMealRef.collection('tarifler').doc(recipeName).set(recipeSnapshot.data() as Map<String, dynamic>);
            } else {
              print('Geçersiz meal_type: $recipeMealType');
            }
          }
        }
      }

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

