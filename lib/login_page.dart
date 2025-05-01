import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore ekleniyor

import 'Cocuk_Profili_Sayfasi.dart';
import 'register_page.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTextField("Kullanıcı Adı", _usernameController),
                SizedBox(height: 15),
                _buildTextField("Şifre", _passwordController, isPassword: true),
                SizedBox(height: 20),
                _buildButton(context, "Giriş Yap", () {
                  if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
                    _showErrorDialog(context, "Kullanıcı adı ve şifre gereklidir.");
                  } else {
                    _signInUser(context);
                  }
                }),
                SizedBox(height: 15),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterPage()),
                    );
                  },
                  child: Text(
                    "Hesabınız yok mu? Kayıt olun",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.7),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        hintText: hint,
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF86A788),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  void _signInUser(BuildContext context) async {
    try {
      String username = _usernameController.text;
      String password = _passwordController.text;

      // Firestore'da kullanıcı adı var mı kontrol et
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (query.docs.isEmpty) {
        _showErrorDialog(context, "Böyle bir kullanıcı adı kayıtlı değil.");
        return;
      }

      // Kullanıcının şifresini al
      String firestorePassword = query.docs.first.get('password');

      // Şifre doğrulaması
      if (password != firestorePassword) {
        _showErrorDialog(context, "Yanlış şifre girdiniz.");
        return;
      }

      // Şifre doğru, kullanıcı başarılı giriş yaptı
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CocukProfilSayfasi()),
      );
    } catch (e) {
      _showErrorDialog(context, "Bir hata oluştu: ${e.toString()}");
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Hata"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Tamam"),
            ),
          ],
        );
      },
    );
  }
}