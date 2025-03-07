import 'package:flutter/material.dart';

import 'package:intl/date_symbol_data_local.dart'; // Yerel tarih formatlama için
import 'package:firebase_core/firebase_core.dart';

import 'Ana_Sayfa.dart';
import 'Favoriler_sayfasi.dart';
import 'Plan_Olusturma_Sayfasi.dart';
import 'Tarifler_sayfasi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter'ın başlatıldığından emin olun
  await initializeDateFormatting('tr_TR', null); // 📌 Türkçe tarih desteğini başlat
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/home',
      routes: {
        '/home': (context) => HomePage(),
        '/plan': (context) => MealPlanHomePage(),
        //'/progress': (context) => ProgressPage(),
        '/recipes': (context) => RecipeListPage(),
        '/favorites': (context) => FavoritesPage(),
        //'/assistant': (context) => AssistantPage(),
        //'/badges': (context) => BadgesPage(),
        //'/settings': (context) => SettingsPage(),
      },
    );
  }
}