import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

User? user = FirebaseAuth.instance.currentUser;
String userId =
    user?.uid ?? ''; // Eğer kullanıcı giriş yapmamışsa boş bir değer alır

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Kullanıcı verisini eklemek
  Future<void> addUser(String userId, String name, String email) async {
    try {
      await _db.collection('users').doc(userId).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print("Kullanıcı başarıyla eklendi.");
    } catch (e) {
      print("Kullanıcı eklenirken hata oluştu: $e");
    }
  }

  // Çocuk verisini children koleksiyonuna eklemek
  Future<void> addChild(String childName, int childAge) async {
    try {
      await _db.collection('children').add({
        'childName': childName,
        'childAge': childAge,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print("Çocuk başarıyla eklendi.");
    } catch (e) {
      print("Çocuk eklenirken hata oluştu: $e");
    }
  }

  // Kullanıcı bilgilerini almak
  Future<DocumentSnapshot> getUser(String userId) async {
    try {
      DocumentSnapshot snapshot =
          await _db.collection('users').doc(userId).get();
      return snapshot;
    } catch (e) {
      print("Kullanıcı bilgileri alınırken hata oluştu: $e");
      rethrow;
    }
  }

  // Kullanıcının çocuklarının listesini almak
  Future<QuerySnapshot> getChildren(String userId) async {
    try {
      QuerySnapshot snapshot =
          await _db
              .collection('users')
              .doc(userId)
              .collection('children')
              .get();
      return snapshot;
    } catch (e) {
      print("Çocuklar alınırken hata oluştu: $e");
      rethrow;
    }
  }

  // Kullanıcı verisini güncellemek
  Future<void> updateUser(String userId, String name, String email) async {
    try {
      await _db.collection('users').doc(userId).update({
        'name': name,
        'email': email,
      });
      print("Kullanıcı başarıyla güncellendi.");
    } catch (e) {
      print("Kullanıcı güncellenirken hata oluştu: $e");
    }
  }

  // Çocuk verisini güncellemek
  Future<void> updateChild(
    String userId,
    String childId,
    String childName,
    int childAge,
  ) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('children')
          .doc(childId)
          .update({'childName': childName, 'childAge': childAge});
      print("Çocuk başarıyla güncellendi.");
    } catch (e) {
      print("Çocuk güncellenirken hata oluştu: $e");
    }
  }

  // Çocuk verisini silmek
  Future<void> deleteChild(String userId, String childId) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('children')
          .doc(childId)
          .delete();
      print("Çocuk başarıyla silindi.");
    } catch (e) {
      print("Çocuk silinirken hata oluştu: $e");
    }
  }

  Future<void> createProfile({
    required String isim,
    required String cinsiyet,
    required DateTime dogumTarihi,
    double? boy,
    double? kilo,
    required String aktiviteDuzeyi,
    required List<String> alerjiler,
    required List<String> hastaliklar,
  }) async {
    try {
      await _db.collection('profiles').add({
        'isim': isim,
        'cinsiyet': cinsiyet,
        'dogumTarihi': Timestamp.fromDate(dogumTarihi),
        'boy': boy,
        'kilo': kilo,
        'aktiviteDuzeyi': aktiviteDuzeyi,
        'alerjiler': alerjiler,
        'hastaliklar': hastaliklar,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print("Profil başarıyla oluşturuldu.");
    } catch (e) {
      print("Profil oluşturulurken hata oluştu: $e");
    }
  }

  // Kullanıcı bilgilerini Firestore'a kaydeden fonksiyon
  Future<void> createUserData({
    required String uid,
    required String email,
    required String username,
  }) async {
    try {
      await _db.collection('users').doc(uid).set({
        'email': email,
        'username': username,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }
}
