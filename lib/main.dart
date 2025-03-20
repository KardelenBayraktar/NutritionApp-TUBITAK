import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart'; // Yerel tarih formatlama için

import 'Ana_Sayfa.dart';
import 'Beslenme_Plani_Sayfasi.dart';
import 'Favoriler_sayfasi.dart';
import 'Oduller_Sayfasi.dart';
import 'Plan_Olusturma_Sayfasi.dart';
import 'Tarifler_sayfasi.dart';
import 'Yapay_Zeka_Sayfasi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter'ın başlatıldığından emin olun
  await initializeDateFormatting('tr_TR', null); // 📌 Türkçe tarih desteğini başlat
  await Firebase.initializeApp();
  // 📌 Aktif beslenme planı olup olmadığını kontrol et
  bool hasActivePlan = await checkActiveMealPlan();

  runApp(MyApp(hasActivePlan: hasActivePlan));
}

class MyApp extends StatelessWidget {
  final bool hasActivePlan;

  MyApp({required this.hasActivePlan});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/home',
      routes: {
        '/home': (context) => HomePage(),
        '/plan': (context) => hasActivePlan ? MealPlanPage() : MealPlanHomePage(), // 📌 Aktif plana göre yönlendirme
        //'/progress': (context) => ProgressPage(),
        '/recipes': (context) => RecipeListPage(),
        '/favorites': (context) => FavoritesPage(),
        '/assistant': (context) => AIPage(),
        '/badges': (context) => RozetlerSayfasi(),
        //'/settings': (context) => SettingsPage(),
      },
    );
  }
}

// 📌 Firestore'dan aktif beslenme planı olup olmadığını kontrol eden fonksiyon
Future<bool> checkActiveMealPlan() async {
  var snapshot = await FirebaseFirestore.instance
      .collection('beslenme_planlari')
      .where('aktif', isEqualTo: true)
      .limit(1)
      .get();

  return snapshot.docs.isNotEmpty; // Eğer aktif plan varsa true döner
}