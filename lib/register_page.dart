import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/image.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Form content
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, left: 20.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(0xFF86A788),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildTextField("İsim", _nameController),
                            SizedBox(height: 15),
                            _buildTextField("E-Posta Adresi", _emailController),
                            SizedBox(height: 15),
                            _buildTextField("Kullanıcı Adı", _usernameController),
                            SizedBox(height: 15),
                            _buildTextField("Şifre", _passwordController, isPassword: true),
                            SizedBox(height: 20),
                            _buildButton("Kayıt Ol", _registerUser),
                            if (_isLoading) SizedBox(height: 20),
                            if (_isLoading) CircularProgressIndicator(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF86A788),
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }

  void _registerUser() async {
    try {
      String username = _usernameController.text.trim();
      String password = _passwordController.text.trim();
      String name = _nameController.text.trim();
      String email = _emailController.text.trim();

      if (username.isEmpty || password.isEmpty || name.isEmpty || email.isEmpty) {
        _showErrorDialog("Lütfen tüm alanları doldurun.");
        return;
      }

      // Firestore'da kullanıcı kaydı yapma
      await FirebaseFirestore.instance.collection('users').add({
        'username': username,
        'password': password,  // Burada şifreyi doğru şekilde eklediğinden emin ol
        'name': name,
        'email': email,
      });

      _showSuccessDialog("Kayıt başarılı!");
    } catch (e) {
      _showErrorDialog("Bir hata oluştu: ${e.toString()}");
    }
  }


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Hata"),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Tamam")),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Icon(Icons.check_circle, size: 48, color: Color(0xFF86A788)),
        content: Text(message, style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // dialog kapansın
              Navigator.pop(context); // önceki sayfaya dön
            },
            child: Text("Tamam"),
          ),
        ],
      ),
    );
  }
}
