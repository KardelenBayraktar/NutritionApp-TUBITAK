import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Kullanıcıyı kaydetme işlemi
  Future<void> signUp({required String email, required String password, required String username}) async {
    try {
      // FirebaseAuth ile kullanıcıyı kaydet
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Firestore'a kullanıcı bilgilerini kaydet
      FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'username': username,
        'password': password,
      });
    } catch (e) {
      throw Exception("Kayıt sırasında hata oluştu: $e");
    }
  }

  // Kullanıcı adı ile Firebase'den kullanıcıyı çekme
  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Firestore'dan alınan ilk dökümanı bir Map olarak döndürüyoruz
        return querySnapshot.docs.first.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("Hata: $e");
      return null;
    }
  }
}
