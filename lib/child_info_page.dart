import 'package:flutter/material.dart';

class ChildInfoPage extends StatelessWidget {
  final TextEditingController _childNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _allergyController = TextEditingController();

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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40.0, left: 20.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTextField("Çocuğun Adı", _childNameController),
                      SizedBox(height: 15),
                      _buildTextField("Yaş", _ageController),
                      SizedBox(height: 15),
                      _buildTextField("Kilo", _weightController),
                      SizedBox(height: 15),
                      _buildTextField("Boy", _heightController),
                      SizedBox(height: 15),
                      _buildTextField("Alerji Bilgisi", _allergyController),
                      SizedBox(height: 20),
                      _buildButton(context, "Kaydı Tamamla", () {
                        if (_childNameController.text.isEmpty || _ageController.text.isEmpty ||
                            _weightController.text.isEmpty || _heightController.text.isEmpty ||
                            _allergyController.text.isEmpty) {
                          _showErrorDialog(context, "Eksik bilgi girdiniz.");
                        } else {
                          // Kayıt işlemleri buraya eklenebilir
                        }
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
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
