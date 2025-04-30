import 'package:flutter/material.dart';
import 'Cocuk_Profili_Sayfasi.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Çocuk Beslenme Takip',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CocukProfilSayfasi(), // Başlangıç ekranı
    );
  }
}