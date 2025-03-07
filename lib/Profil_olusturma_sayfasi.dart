import 'package:flutter/material.dart';

class ChildProfilePage extends StatefulWidget {
  @override
  _ChildProfilePageState createState() => _ChildProfilePageState();
}

class _ChildProfilePageState extends State<ChildProfilePage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _surnameController = TextEditingController();
  TextEditingController _heightController = TextEditingController();
  TextEditingController _weightController = TextEditingController();

  String? _selectedGender;
  String? _selectedBloodType;

  final List<String> _genders = ["Erkek", "Kız"];
  final List<String> _bloodTypes = ["A+", "A-", "B+", "B-", "AB+", "AB-", "0+", "0-"];

  void _createProfile() {
    if (_nameController.text.isEmpty ||
        _surnameController.text.isEmpty ||
        _selectedGender == null ||
        _heightController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _selectedBloodType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Eksik bilgi girdiniz!"),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Profil oluşturuldu!"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Çocuk Profili Oluştur")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Ad"),
              ),
              TextFormField(
                controller: _surnameController,
                decoration: InputDecoration(labelText: "Soyad"),
              ),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                hint: Text("Cinsiyet Seç"),
                items: _genders.map((gender) {
                  return DropdownMenuItem(value: gender, child: Text(gender));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
              ),
              TextFormField(
                controller: _heightController,
                decoration: InputDecoration(labelText: "Boy (cm)"),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(labelText: "Kilo (kg)"),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                value: _selectedBloodType,
                hint: Text("Kan Grubu Seç"),
                items: _bloodTypes.map((bloodType) {
                  return DropdownMenuItem(value: bloodType, child: Text(bloodType));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBloodType = value;
                  });
                },
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _createProfile,
                  child: Text("Profili Oluştur"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
