import 'package:beslenme_takip_sistemi/Beslenme_Plani_Sayfasi.dart';
import 'package:beslenme_takip_sistemi/Bir_tarif_sayfasi.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter'ın başlatıldığından emin olun
  await initializeDateFormatting('tr_TR', null); // 📌 Türkçe tarih desteğini başlat
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RecipeDetailPage(recipeId: 'TCvNJse2g9bJK6yIFPFg',),
    );
  }
}

//Bu class diğer sayfaları tek tek test etmek için oluşturulmuştur.