import 'package:flutter/material.dart';

import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'Beslenme_Plani_Sayfasi.dart';

class ManualPlanPage extends StatefulWidget {
  @override
  _ManualPlanPageState createState() => _ManualPlanPageState();
}

class _ManualPlanPageState extends State<ManualPlanPage> {
  TextEditingController planNameController = TextEditingController();
  List<DateTime> selectedDays = [];
  Map<DateTime, Map<String, List<String>>> mealPlans = {};
  DateTime? selectedDate;
  DateTime focusedDay = DateTime.now();
  Map<DateTime, bool> showMeals = {};

  final List<String> mealTypes = ["Kahvaltı", "Öğle Yemeği", "Akşam Yemeği", "Ara Öğün"];

  void addDay(DateTime day) {
    if (!selectedDays.contains(day)) {
      setState(() {
        selectedDays.add(day);
        selectedDays.sort();
        mealPlans[day] = {for (var meal in mealTypes) meal: []};
        showMeals[day] = false;
      });
    }
  }

  void addRecipe(String mealType, String recipe) {
    if (selectedDate != null) {
      if (!mealPlans[selectedDate!]![mealType]!.contains(recipe)) {
        setState(() {
          mealPlans[selectedDate!]![mealType]!.add(recipe);
        });
      }
    }
  }

  void showRecipeSelection(String mealType) async {
    if (selectedDate == null) return;

    final selectedRecipe = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeSelectionPage(),
      ),
    );

    if (selectedRecipe != null) {
      addRecipe(mealType, selectedRecipe);
    }
  }

  void showCalendarDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SizedBox(
            height: 400,
            width: 300,
            child: TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: focusedDay,
              selectedDayPredicate: (day) => selectedDays.contains(day),
              onDaySelected: (selectedDay, focusedDay) {
                addDay(selectedDay);
                setState(() {
                  this.focusedDay = focusedDay;
                  selectedDate = selectedDay;
                });
                Navigator.pop(context);
              },
              calendarFormat: CalendarFormat.month,
            ),
          ),
        );
      },
    );
  }

  Future<void> savePlanToFirestore() async {
    String planName = planNameController.text.trim();
    Map<DateTime, List<String>> dailyRecipes = {}; // Gün ve tarifleri saklamak için

    // mealPlans içindeki verileri dönüştürme
    mealPlans.forEach((date, meals) {
      // İçteki map'in tüm listelerini birleştiriyoruz
      List<String> allMeals = meals.values.expand((mealList) => mealList).toList();
      dailyRecipes[date] = allMeals;
    });

    // Sonucu yazdıralım
    print(dailyRecipes);

    if (planName.isEmpty || selectedDays.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Uyarı"),
            content: Text("Lütfen plan adı girin ve en az bir gün seçin."),
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
      return;
    }

    print("Manuel oluşturulan beslenme planı:");
    dailyRecipes.forEach((day, recipes) {
      print("${DateFormat('yyyy-MM-dd').format(day)}: ${recipes.join(', ')}");
    });

    try {
      // Önceki aktif planları pasif hale getir
      var previousPlans = await FirebaseFirestore.instance
          .collection('beslenme_planlari')
          .where('aktif', isEqualTo: true)
          .get();

      for (var doc in previousPlans.docs) {
        await doc.reference.update({'aktif': false});
      }

      print("Yeni beslenme planı ekleniyor...");
      DocumentReference mealPlanRef = await FirebaseFirestore.instance.collection('beslenme_planlari').add({
        'created_at': FieldValue.serverTimestamp(),
        'aktif': true,
      });
      print("Beslenme planı eklendi: ${mealPlanRef.id}");

      List<String> mealTypes = ['Kahvaltı', 'Öğle Yemeği', 'Akşam Yemeği', 'Ara Öğünler'];

      for (DateTime day in dailyRecipes.keys) {
        String isoDate = DateFormat('yyyy-MM-dd').format(day);
        CollectionReference dailyPlanRef = mealPlanRef.collection(isoDate);
        print("Alt koleksiyon oluşturuldu: $isoDate");

        for (String mealType in mealTypes) {
          DocumentReference mealRef = dailyPlanRef.doc(mealType);
          await mealRef.set({
            'meal_type': mealType,
            'created_at': FieldValue.serverTimestamp(),
          });
          print("Öğün eklendi: $mealType - $isoDate");

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

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Başarılı"),
            content: Text("Beslenme planı oluşturuldu"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/plan');
                },
                child: Text("Tamam"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Hata"),
            content: Text("Beslenme planı oluşturulurken bir hata oluştu: $e"),
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
      appBar: AppBar(title: Text("Manuel Beslenme Planı")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: planNameController,
              decoration: InputDecoration(labelText: "Beslenme Planı Adı"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: showCalendarDialog,
              child: Text("Gün Ekle"),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: selectedDays.length,
                itemBuilder: (context, index) {
                  DateTime day = selectedDays[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text("${day.toLocal()}".split(' ')[0]),
                        trailing: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showMeals[day] = !showMeals[day]!;
                              selectedDate = day;
                            });
                          },
                          child: Text(showMeals[day]! ? "Öğünleri Gizle" : "Öğünleri Göster"),
                        ),
                      ),
                      if (showMeals[day]!)
                        Column(
                          children: mealTypes.map((mealType) {
                            return Card(
                              child: ListTile(
                                title: Text(mealType),
                                trailing: IconButton(
                                  icon: Icon(Icons.add_box),
                                  onPressed: () => showRecipeSelection(mealType),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: (mealPlans[day]?[mealType] ?? []).map((recipe) => Text(recipe)).toList(),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: savePlanToFirestore,
                child: Text("Beslenme Planını Oluştur"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecipeSelectionPage extends StatefulWidget {
  @override
  _RecipeSelectionPageState createState() => _RecipeSelectionPageState();
}

class _RecipeSelectionPageState extends State<RecipeSelectionPage> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, String>> recipes = [];
  List<Map<String, String>> filteredRecipes = [];

  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }

  void fetchRecipes() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('tarifler').get();
    List<Map<String, String>> fetchedRecipes = querySnapshot.docs.map((doc) => {
      "name": doc['name'].toString(),
      "mealType": doc['meal_type'].toString()
    }).toList();
    setState(() {
      recipes = fetchedRecipes;
      filteredRecipes = fetchedRecipes;
    });
  }

  void filterRecipes(String query) {
    setState(() {
      filteredRecipes = recipes.where((recipe) => recipe["name"]!.toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tarif Seç")),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Tarif Ara",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: filterRecipes,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredRecipes.length,
              itemBuilder: (context, index) {
                var recipe = filteredRecipes[index];
                return ListTile(
                  title: Text(recipe["name"]!),
                  trailing: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      recipe["mealType"]!,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context, recipe["name"]!);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}