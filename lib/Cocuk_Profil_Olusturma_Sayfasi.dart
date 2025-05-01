import 'package:beslenme_takip_sistemi/Ana_Sayfa.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/firestore_services.dart';

class CocukProfilOlusturmaSayfasi extends StatefulWidget {
  @override
  _CocukProfilOlusturmaSayfasiState createState() =>
      _CocukProfilOlusturmaSayfasiState();
}

class _CocukProfilOlusturmaSayfasiState
    extends State<CocukProfilOlusturmaSayfasi> {
  int _aktifAdim = 0;

  String _isim = '';
  String _cinsiyet = '';
  DateTime? _dogumTarihi;
  double? _boy;
  double? _kilo;
  String _aktiviteDuzeyi = '';
  Map<int, bool> showInfo = {0: false, 1: false, 2: false};
  String? _alerjiVarMi;
  List<String> _seciliAlerjiler = [];
  String? _hastalikVarMi;
  List<String> _seciliHastaliklar = [];

  final TextEditingController _isimController = TextEditingController();
  final TextEditingController _boyController = TextEditingController();
  final TextEditingController _kiloController = TextEditingController();
  final TextEditingController _digerAlerjiController = TextEditingController();
  final TextEditingController _digerHastalikController =
  TextEditingController();

  void _ileriGit() {
    if (_aktifAdim < 7) {
      setState(() {
        _aktifAdim++;
      });
    } else {
      _asamaVerisiniKaydet(); // en son veriyi de kaydet
      _veriKaydet(); // 🔹 Firebase'e kaydet
    }
  }


  void _veriKaydet() async {
    if (_dogumTarihi == null ||
        _isim.isEmpty ||
        _cinsiyet.isEmpty ||
        _aktiviteDuzeyi.isEmpty) {
      // Verilerin eksik olduğunu kontrol edin.
      return;
    }

    try {
      await FirestoreService().createProfile(
        isim: _isim,
        cinsiyet: _cinsiyet,
        dogumTarihi: _dogumTarihi!,
        boy: _boy,
        kilo: _kilo,
        aktiviteDuzeyi: _aktiviteDuzeyi,
        alerjiler: _seciliAlerjiler,
        hastaliklar: _seciliHastaliklar,
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      // Hata mesajı gösterilebilir.
      print("Hata: $e");
    }
  }

  void _geriGit() {
    if (_aktifAdim > 0) {
      setState(() {
        _aktifAdim--;
      });
    }
  }

  Widget _adimIcerigi() {
    switch (_aktifAdim) {
      case 0:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Çocuğunuzun ismini girin",
              style: TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                controller: _isimController,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintText: "İsim",
                ),
              ),
            ),
          ],
        );

      case 1:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Cinsiyet Seçin",
              style: TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 20),
            ToggleButtons(
              isSelected: [_cinsiyet == 'Erkek', _cinsiyet == 'Kız'],
              onPressed: (index) {
                setState(() {
                  _cinsiyet = index == 0 ? 'Erkek' : 'Kız';
                });
              },
              borderRadius: BorderRadius.circular(12),
              selectedColor: Colors.white,
              fillColor: Color(0xFF86A788),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Erkek',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Kız',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );

      case 2:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Doğum Tarihini Seçin",
              style: TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final secilenTarih = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2020),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (secilenTarih != null) {
                    setState(() {
                      _dogumTarihi = secilenTarih;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF86A788),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  _dogumTarihi == null
                      ? "Tarih Seç"
                      : DateFormat('dd.MM.yyyy').format(_dogumTarihi!),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                  ),
                ),
              ),
            ),
          ],
        );

      case 3:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Boy ve Kilo Bilgisi",
              style: TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                controller: _boyController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintText: "Boy (cm)",
                ),
                style: TextStyle(fontSize: 20),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                controller: _kiloController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintText: "Kilo (kg)",
                ),
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        );

      case 4:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  "Çocuğunuzun gün içindeki fiziksel aktivite düzeyini en iyi anlatan seçeneği seçin:",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            ...List.generate(3, (index) {
              final secenekler = ["Çok Az Aktif", "Orta Aktif", "Aktif"];
              final aciklamalar = [
                "🔸 “Çocuğum gün içinde çok az hareket ediyor. Yürümüyor ya da emeklemiyor. Genellikle oturuyor ya da yatıyor.”\n- Henüz yürümeyen bebekler\n- Hareket kısıtlı, genellikle taşınan çocuklar\n- Sağlık sorunları nedeniyle aktif olmayanlar",
                "🔸 “Çocuğum zaman zaman emekliyor, kısa süreli oyunlar oynuyor veya yürüyor ama çok uzun süre aktif kalmıyor.”\n- Emeklemeye başlamış bebekler\n- Yeni yürümeye başlayan çocuklar (1–2 yaş)\n- Oyunla ilgileniyor ama uzun süre aktif değil",
                "🔸 “Çocuğum yürüyebiliyor, sık sık hareket ediyor, oyun oynuyor, dışarıda koşuyor ve enerjik.”\n- Gün içinde koşma, zıplama gibi hareketler yapıyor\n- Oyuncaklarla aktif şekilde oynuyor\n- Günde en az 3–4 saat aktif zaman geçiriyor",
              ];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Theme(
                          data: Theme.of(context).copyWith(
                            unselectedWidgetColor: Colors.white70,
                          ),
                          child: Radio<String>(
                            activeColor: Colors.white, // Beyaz nokta
                            value: secenekler[index],
                            groupValue: _aktiviteDuzeyi,
                            onChanged: (value) {
                              setState(() {
                                _aktiviteDuzeyi = value!;
                              });
                            },
                          ),
                        ),
                        title: Text(
                          secenekler[index],
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.help_outline, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              showInfo[index] = !(showInfo[index] ?? false);
                            });
                          },
                        ),
                      ),
                      if (showInfo[index] == true)
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            aciklamalar[index],
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );


      case 5:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                "Çocuğunuzun bilinen bir gıda alerjisi veya intoleransı var mı?",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: Text(
                    "Evet",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  selected: _alerjiVarMi == "Evet",
                  onSelected: (selected) {
                    setState(() {
                      _alerjiVarMi = "Evet";
                    });
                  },
                ),
                SizedBox(width: 10),
                ChoiceChip(
                  label: Text(
                    "Hayır",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  selected: _alerjiVarMi == "Hayır",
                  onSelected: (selected) {
                    setState(() {
                      _alerjiVarMi = "Hayır";
                      _seciliAlerjiler.clear();
                      _digerAlerjiController.clear();
                    });
                  },
                ),
              ],
            ),
            if (_alerjiVarMi == "Evet") ...[
              SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children:
                [
                  "Süt/Laktoz",
                  "Gluten",
                  "Yumurta",
                  "Yer fıstığı",
                  "Ağaç yemişleri (badem, ceviz vb.)",
                  "Balık",
                  "Kabuklu deniz ürünleri",
                  "Soya",
                  "Çikolata / Kakao",
                  "Bal",
                  "Aşırı tuz hassasiyeti",
                  "Baharatlara duyarlılık",
                ].map((alerji) {
                  return FilterChip(
                    label: Text(alerji),
                    selected: _seciliAlerjiler.contains(alerji),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _seciliAlerjiler.add(alerji);
                        } else {
                          _seciliAlerjiler.remove(alerji);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  controller: _digerAlerjiController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: "Diğer (lütfen belirtiniz)",
                  ),
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ],
        );

      case 6:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                "Çocuğunuzda tanı konmuş bir beslenme veya metabolizma hastalığı var mı?",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: Text(
                    "Evet",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  selected: _hastalikVarMi == "Evet",
                  onSelected: (selected) {
                    setState(() {
                      _hastalikVarMi = "Evet";
                    });
                  },
                ),
                SizedBox(width: 10),
                ChoiceChip(
                  label: Text(
                    "Hayır",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  selected: _hastalikVarMi == "Hayır",
                  onSelected: (selected) {
                    setState(() {
                      _hastalikVarMi = "Hayır";
                      _seciliHastaliklar.clear();
                      _digerHastalikController.clear();
                    });
                  },
                ),
              ],
            ),
            if (_hastalikVarMi == "Evet") ...[
              SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children:
                [
                  "Fenilketonüri (PKU)",
                  "Çölyak Hastalığı",
                  "Tip 1 Diyabet",
                  "Tip 2 Diyabet",
                  "Galaktozemi",
                  "Fruktoz İntoleransı",
                  "Maple Syrup Urine Disease (MSUD)",
                  "Glikojen Depo Hastalıkları",
                  "Obezite",
                  "Anemi (Demir eksikliği)",
                  "Raşitizm (D vitamini eksikliği)",
                  "Malnütrisyon (Yetersiz beslenme)",
                  "İyot eksikliği",
                  "Hipervitaminosis (Aşırı vitamin alımı)",
                ].map((hastalik) {
                  return FilterChip(
                    label: Text(hastalik),
                    selected: _seciliHastaliklar.contains(hastalik),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _seciliHastaliklar.add(hastalik);
                        } else {
                          _seciliHastaliklar.remove(hastalik);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  controller: _digerAlerjiController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: "Diğer (lütfen belirtiniz)",
                  ),
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ],
        );

    // >>> BURAYA DİĞER AŞAMALAR EKLENECEK <<<

      default:
        return Text(
          "Tamamlandı",
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        );
    }
  }

  void _asamaVerisiniKaydet() {
    switch (_aktifAdim) {
      case 0:
        _isim = _isimController.text.trim();
        break;
      case 3:
        _boy = double.tryParse(_boyController.text.trim());
        _kilo = double.tryParse(_kiloController.text.trim());
        break;
      case 4:
      // Aktivite düzeyi zaten _aktiviteDuzeyi içinde tutuluyor
        break;
      case 5:
        if (_alerjiVarMi == "Evet") {
          if (_digerAlerjiController.text.trim().isNotEmpty) {
            _seciliAlerjiler.add(_digerAlerjiController.text.trim());
          }
        }
        break;
      case 6:
        if (_hastalikVarMi == "Evet") {
          if (_digerHastalikController.text.trim().isNotEmpty) {
            _seciliHastaliklar.add(_digerHastalikController.text.trim());
          }
        }
        break;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Çocuk Profili Oluştur",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF86A788),
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/image.png',
              fit: BoxFit.cover,
            ),
          ),
          // Content
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _adimIcerigi(),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_aktifAdim > 0)
                        SizedBox(
                          width: 150,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _geriGit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF86A788),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(
                              "Geri Git",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white
                              ),
                            ),
                          ),
                        ),
                      if (_aktifAdim > 0)
                        SizedBox(width: 20),
                      SizedBox(
                        width: 150,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            _asamaVerisiniKaydet();
                            _ileriGit();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF86A788),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(
                            _aktifAdim < 7 ? "Devam Et" : "Tamamla",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}