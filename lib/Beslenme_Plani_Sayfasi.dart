import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    'Mineraller': 0,
  };

  @override
  void initState() {
    super.initState();
    _fetchLatestMealPlan(); // En son beslenme planını çek
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
      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate); // Tarihi uygun formata getir
      print("formattedDate: $formattedDate"); // debug için ekleyin
      CollectionReference dayRef = FirebaseFirestore.instance
          .collection('beslenme_planlari')
          .doc(planId)
          .collection(formattedDate);

      QuerySnapshot snapshot = await dayRef.get(); // Belirtilen günün yemek planını getir

      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          String mealType = doc.id; // Kahvaltı, Öğle, Akşam gibi öğün isimleri

          // Alt koleksiyon olan "tarifler"i çek
          CollectionReference tariflerRef = dayRef.doc(mealType).collection('tarifler');
          QuerySnapshot tariflerSnapshot = await tariflerRef.get();

          List<String> meals = [];
          for (var tarifDoc in tariflerSnapshot.docs) {
            meals.add(tarifDoc.id); // Tarif ismi olarak belge ID'lerini al
          }

          setState(() {
            mealPlan[mealType] = meals;
            nutritionTotals.updateAll((key, value) => 0);
          });
        }
      } else {
        print("Bu gün için beslenme planı bulunamadı.");
        setState(() {
          mealPlan.clear();
          nutritionTotals.updateAll((key, value) => 0); // Besin değerlerini sıfırla
        });
      }
    } catch (e) {
      print("Beslenme planı çekilemedi: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Beslenme Planı')),
      body: Column(
        children: [
          _buildCalendar(), // Takvim widget'ını oluştur
          Expanded(child: _buildMealPlan()), // Öğün listesini gösteren widget
          _buildNutritionCard(), // Besin değerlerini gösteren widget
        ],
      ),
    );
  }

  // Takvim arayüzünü oluşturur
  Widget _buildCalendar() {
    DateTime startOfWeek = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));

    return Column(
      children: [
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (index) {
            DateTime day = startOfWeek.add(Duration(days: index));
            String dayLabel = DateFormat('E', 'tr').format(day);
            String dateLabel = DateFormat('dd/MM').format(day);
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
                    backgroundColor: isSelected ? Colors.green : Colors.grey[300],
                    child: Text(
                      dateLabel,
                      style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 14),
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
      return Center(child: Text('Bu gün için bir plan bulunmamaktadır.'));
    }

    return ListView(
      padding: EdgeInsets.all(8.0),
      children: mealPlan.entries.map((entry) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              ListTile(
                title: Text(
                  entry.key, // Kahvaltı, Öğle, Akşam gibi öğün başlığı
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
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            print("$meal tıklandı");
                          },
                          child: Text(
                            meal,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blue),
                          ),
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
      child: Column(
        children: nutritionTotals.entries.map((entry) => _buildNutritionRow(entry.key, entry.value, 100)).toList(),
      ),
    );
  }

  // Besin değeri için gösterge çubuğu oluşturur
  Widget _buildNutritionRow(String label, double value, double max) {
    double progress = (max == 0) ? 0 : value / max;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(label), Text("${value.toInt()} / ${max.toInt()}")],
        ),
        LinearProgressIndicator(value: progress, backgroundColor: Colors.grey[300], valueColor: AlwaysStoppedAnimation<Color>(Colors.green)),
      ],
    );
  }
}
