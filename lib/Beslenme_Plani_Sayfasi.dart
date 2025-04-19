import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'Bir_tarif_sayfasi.dart';
import 'Manuel_Plan_Olusturma_Sayfasi.dart';
import 'Plan_Olusturma_Sayfasi.dart';


class MealPlanPage extends StatefulWidget {
  @override
  _MealPlanPageState createState() => _MealPlanPageState();
}

class _MealPlanPageState extends State<MealPlanPage> {
  // Kullanıcının seçtiği tarih (varsayılan olarak bugünün tarihi)
  DateTime selectedDate = DateTime.now();
  String planId = "";
  // Öğün planlarını saklayan harita ("Kahvaltı": ["Yumurta", "Ekmek"] gibi)
  Map<String, List<String>> mealPlan = {};
  // Besin değerlerini tutan map (toplam kaloriler vb.)
  Map<String, double> nutritionTotals = {
    'Kalori': 0,
    'Karbonhidrat': 0,
    'Protein': 0,
    'Yağ': 0,
  };

  Map<String, double> consumedNutrition = {
    'Kalori': 0,
    'Karbonhidrat': 0,
    'Protein': 0,
    'Yağ': 0,
  };

  // Yemeklerin tüketim durumunu takip eden map
  Map<String, Map<String, bool>> consumedMeals = {};

  // Her yemeğin besin değerlerini tutan map
  Map<String, Map<String, Map<String, double>>> mealNutritionValues = {};

  @override
  void initState() {
    super.initState();
    _fetchLatestMealPlan(); // En son beslenme planını çek
  }

  // Öğün tüketildiğinde besin değerlerini güncelle
  void _updateConsumedNutrition(String mealType, String meal, bool isConsumed) {
    setState(() {
      if (!consumedMeals.containsKey(mealType)) {
        consumedMeals[mealType] = {};
      }
      consumedMeals[mealType]![meal] = isConsumed;

      // Tüketilen besin değerlerini sıfırla
      consumedNutrition.updateAll((key, value) => 0);

      // Tüm tüketilen öğünlerin besin değerlerini topla
      consumedMeals.forEach((type, meals) {
        meals.forEach((mealName, consumed) {
          if (consumed && mealNutritionValues.containsKey(type) && 
              mealNutritionValues[type]!.containsKey(mealName)) {
            var nutrition = mealNutritionValues[type]![mealName]!;
            consumedNutrition['Kalori'] = (consumedNutrition['Kalori'] ?? 0) + (nutrition['Kalori'] ?? 0);
            consumedNutrition['Karbonhidrat'] = (consumedNutrition['Karbonhidrat'] ?? 0) + (nutrition['Karbonhidrat'] ?? 0);
            consumedNutrition['Protein'] = (consumedNutrition['Protein'] ?? 0) + (nutrition['Protein'] ?? 0);
            consumedNutrition['Yağ'] = (consumedNutrition['Yağ'] ?? 0) + (nutrition['Yağ'] ?? 0);
          }
        });
      });
    });
  }

  // Firebase'den en son oluşturulan beslenme planını getirir
  Future<void> _fetchLatestMealPlan() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('beslenme_planlari')
          .orderBy('created_at', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        planId = snapshot.docs.first.id; // En son planın ID'sini al
        print("planId: $planId"); // debug için ekleyin
        setState(() {
          selectedDate = DateTime.now();
        });
        print("Beslenme planı başarıyla çekildi.");
        await _fetchMealPlan(selectedDate); // Günlük öğün planını getir
      } else {
        print("Beslenme planı bulunamadı.");
        setState(() {
          mealPlan.clear();
          nutritionTotals.updateAll((key, value) => 0);
        });
      }
    } catch (e) {
      print("Beslenme planı çekilemedi: $e");
    }
  }

  // Belirtilen tarihteki beslenme planını Firebase'den çeker
  Future<void> _fetchMealPlan(DateTime selectedDate) async {
    try {
      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
      print("formattedDate: $formattedDate");
      CollectionReference dayRef = FirebaseFirestore.instance
          .collection('beslenme_planlari')
          .doc(planId)
          .collection(formattedDate);

      QuerySnapshot snapshot = await dayRef.get();

      if (snapshot.docs.isNotEmpty) {
        Map<String, double> tempNutritionTotals = {
          "Kalori": 0,
          "Karbonhidrat": 0,
          "Protein": 0,
          "Yağ": 0,
        };

        for (var doc in snapshot.docs) {
          String mealType = doc.id;
          CollectionReference tariflerRef = dayRef.doc(mealType).collection('tarifler');
          QuerySnapshot tariflerSnapshot = await tariflerRef.get();

          List<String> meals = [];
          if (!mealNutritionValues.containsKey(mealType)) {
            mealNutritionValues[mealType] = {};
          }

          for (var tarifDoc in tariflerSnapshot.docs) {
            meals.add(tarifDoc.id);
            Map<String, dynamic>? besinDegerleri = tarifDoc.get("besinDeğerleri");

            if (besinDegerleri != null) {
              // Besin değerlerini mealNutritionValues'a kaydet
              mealNutritionValues[mealType]![tarifDoc.id] = {
                'Kalori': (besinDegerleri['Kalori'] ?? 0).toDouble(),
                'Karbonhidrat': (besinDegerleri['Karbonhidrat'] ?? 0).toDouble(),
                'Protein': (besinDegerleri['Protein'] ?? 0).toDouble(),
                'Yağ': (besinDegerleri['Yağ'] ?? 0).toDouble(),
              };

              tempNutritionTotals["Kalori"] = (tempNutritionTotals["Kalori"] ?? 0) + (besinDegerleri["Kalori"] ?? 0);
              tempNutritionTotals["Karbonhidrat"] = (tempNutritionTotals["Karbonhidrat"] ?? 0) + (besinDegerleri["Karbonhidrat"] ?? 0);
              tempNutritionTotals["Protein"] = (tempNutritionTotals["Protein"] ?? 0) + (besinDegerleri["Protein"] ?? 0);
              tempNutritionTotals["Yağ"] = (tempNutritionTotals["Yağ"] ?? 0) + (besinDegerleri["Yağ"] ?? 0);
            }
          }

          setState(() {
            mealPlan[mealType] = meals;
          });
        }

        setState(() {
          nutritionTotals = tempNutritionTotals;
        });

      } else {
        print("Bu gün için beslenme planı bulunamadı.");
        setState(() {
          mealPlan.clear();
          nutritionTotals.updateAll((key, value) => 0);
        });
      }
    } catch (e) {
      print("Beslenme planı çekilemedi: $e");
    }
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

  Future<void> loadPreviousPlan() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // En güncel ve bir önceki planı almak için sorgu
      QuerySnapshot querySnapshot = await firestore
          .collection("beslenme_planları")
          .orderBy("timestamp", descending: true) // Yeniden eskiye sıralama
          .limit(2) // Son iki planı al
          .get();

      if (querySnapshot.docs.length > 1) {
        // 1. En güncel plan (aktif olan)
        DocumentSnapshot latestPlan = querySnapshot.docs[0];

        // 2. Bir önceki plan (geri yüklemek istediğimiz)
        DocumentSnapshot previousPlan = querySnapshot.docs[1];

        // En güncel planın aktiflik durumunu false yap
        await firestore.collection("beslenme_planları").doc(latestPlan.id).update({
          "aktif": false,
        });

        // Önceki planı aktif hale getir
        await firestore.collection("beslenme_planları").doc(previousPlan.id).update({
          "aktif": true,
        });

        // Planı ekrana yükle
        Map<String, dynamic> planData = previousPlan.data() as Map<String, dynamic>;

        setState(() {
          planId = previousPlan.id;
          selectedDate = DateTime.now(); // Geri yüklenen planın tarihi
          mealPlan.clear();
          nutritionTotals.updateAll((key, value) => 0);
        });

        // Günlük planı çek
        await _fetchMealPlan(selectedDate);

        print("Önceki plan başarıyla yüklendi!");
      } else {
        print("Önceki bir plan bulunamadı.");
      }
    } catch (e) {
      print("Önceki plan yüklenirken hata oluştu: $e");
    }
  }

  // Başarı mesajını içeren popup
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Başarılı"),
          content: Text("Beslenme planı başarıyla silindi."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Önce dialog kapatılır
                Navigator.pushReplacementNamed(context, "/plan"); // Yeni sayfaya yönlendirme
              },
              child: Text("Tamam"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Geri tuşuna basıldığında Ana Sayfa'ya yönlendir
        Navigator.pushReplacementNamed(context, "/home");
        return false; // Sayfayı kapatma, yönlendirme yap
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Beslenme Planı')),
        body: SingleChildScrollView( // Tüm sayfa kaydırılabilir olacak
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCalendar(), // Takvim widget'ını oluştur
              _buildMealPlan(), // Öğün listesi
              _buildNutritionCard(), // Besin değerlerini gösteren widget
              Center(  // Butonu yatayda ortalamak için Center widget'ı ekliyoruz
                child: ElevatedButton(
                  onPressed: () {
                    _showPlanOptionsDialog(context);
                  },
                  child: Text("Yeni bir beslenme planı oluştur"),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                    foregroundColor: Colors.black,
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 20),  // Butonun altında boşluk
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    loadPreviousPlan;
                  },
                  child: Text("Önceki Planı Yükle"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF86A788),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                    textStyle: TextStyle(fontSize: 16 ),
                  ),
                ),
              ),
              SizedBox(height: 20), // Butonun altında boşluk
            ],
          ),
        ),
      ),
    );
  }
// Takvim arayüzünü oluşturur
  Widget _buildCalendar() {
    DateTime startOfWeek = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));

    return Column(
      children: [
        // Ay ve yıl gösterimi
        Text(
          DateFormat('MMMM yyyy', 'tr').format(selectedDate), // "Mart 2025" formatı
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),

        // Hafta değiştirme butonları
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  selectedDate = selectedDate.subtract(Duration(days: 7));
                });
                _fetchMealPlan(selectedDate);
              },
            ),
            Text(
              "Hafta: ${DateFormat('d MMM', 'tr').format(startOfWeek)} - ${DateFormat('d MMM', 'tr').format(startOfWeek.add(Duration(days: 6)))}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: () {
                setState(() {
                  selectedDate = selectedDate.add(Duration(days: 7));
                });
                _fetchMealPlan(selectedDate);
              },
            ),
          ],
        ),
        SizedBox(height: 8),

        // Günlerin gösterimi
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (index) {
            DateTime day = startOfWeek.add(Duration(days: index));
            String dayLabel = DateFormat('E', 'tr').format(day);
            String dateLabel = DateFormat('d').format(day); // Sadece gün numarası

            bool isSelected = day.day == selectedDate.day;

            return Column(
              children: [
                Text(dayLabel, style: TextStyle(fontSize: 12)),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDate = day;
                    });
                    _fetchMealPlan(selectedDate);
                  },
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: isSelected ? Color(0xFF86A788) : Colors.grey[300],
                    child: Text(
                      dateLabel,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }


  // Günlük öğünleri listeleyen widget
  Widget _buildMealPlan() {
    if (mealPlan.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'Bu gün için bir plan bulunmamaktadır.',
            style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(8.0),
      children: mealPlan.entries.map((entry) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              ListTile(
                title: Text(
                  entry.key,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              Divider(),
              entry.value.isEmpty
                  ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    "Tarif bulunmamaktadır",
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
                  : Column(
                children: entry.value.map((meal) {
                  bool isConsumed = consumedMeals[entry.key]?[meal] ?? false;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: isConsumed,
                              onChanged: (bool? value) {
                                _updateConsumedNutrition(entry.key, meal, value ?? false);
                              },
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RecipeDetailPage(tarifAdi: meal),
                                  ),
                                );
                              },
                              child: Text(
                                meal,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF86A788)),
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            print("$meal için alternatifler gösterilecek");
                          },
                          child: Text("Alternatifleri Gör", style: TextStyle(fontSize: 14)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 8),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Besin değerlerini gösteren widget
  Widget _buildNutritionCard() {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tüketilen Besin Değerleri',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ...nutritionTotals.entries.map((entry) {
              double consumedValue = consumedNutrition[entry.key] ?? 0;
              double totalValue = entry.value;
              double percentage = totalValue > 0 ? (consumedValue / totalValue) * 100 : 0;
              
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key),
                      Text("${consumedValue.toInt()} / ${totalValue.toInt()} (${percentage.toStringAsFixed(1)}%)"),
                    ],
                  ),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF86A788)),
                  ),
                  SizedBox(height: 8),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}




