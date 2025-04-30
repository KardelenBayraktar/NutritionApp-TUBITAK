import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CocukProfilOlusturmaSayfasi extends StatefulWidget {
  @override
  _CocukProfilOlusturmaSayfasiState createState() =>
      _CocukProfilOlusturmaSayfasiState();
}

class _CocukProfilOlusturmaSayfasiState extends State<CocukProfilOlusturmaSayfasi> {
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
  final TextEditingController _digerHastalikController = TextEditingController();

  void _ileriGit() {
    if (_aktifAdim < 7) {
      setState(() {
        _aktifAdim++;
      });
    } else {
      // Tüm veriler girildikten sonra burada işlemler yapılabilir
      print("İsim: $_isim");
      print("Cinsiyet: $_cinsiyet");
      print("Doğum Tarihi: $_dogumTarihi");
      print("Boy: $_boy");
      print("Kilo: $_kilo");
      print("Fiziksel Aktivite Düzeyi: $_aktiviteDuzeyi");
      print("Alerji Var mı?: $_alerjiVarMi");
      print("Seçili Alerjiler: $_seciliAlerjiler");
      print("Hastalık Var mı?: $_hastalikVarMi");
      print("Seçili Hastalıklar: $_seciliHastaliklar");

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => YeniSayfa()),
            (Route<dynamic> route) => false,
      );
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
              style: TextStyle(fontSize: 22),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                controller: _isimController,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
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
              style: TextStyle(fontSize: 22),
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
              fillColor: Colors.blue,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Erkek', style: TextStyle(fontSize: 18)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Kız', style: TextStyle(fontSize: 18)),
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
              style: TextStyle(fontSize: 22),
            ),
            SizedBox(height: 20),
            ElevatedButton(
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
              child: Text(
                _dogumTarihi == null
                    ? "Tarih Seç"
                    : DateFormat('dd.MM.yyyy').format(_dogumTarihi!),
                style: TextStyle(fontSize: 18),
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
              style: TextStyle(fontSize: 22),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                controller: _boyController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
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
                  border: OutlineInputBorder(),
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
            Text(
              "Çocuğunuzun gün içindeki fiziksel aktivite düzeyini en iyi anlatan seçeneği seçin:",
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ...List.generate(3, (index) {
              final secenekler = ["Çok Az Aktif", "Orta Aktif", "Aktif"];
              final aciklamalar = [
                "🔸 “Çocuğum gün içinde çok az hareket ediyor. Yürümüyor ya da emeklemiyor. Genellikle oturuyor ya da yatıyor.”\n- Henüz yürümeyen bebekler\n- Hareket kısıtlı, genellikle taşınan çocuklar\n- Sağlık sorunları nedeniyle aktif olmayanlar",
                "🔸 “Çocuğum zaman zaman emekliyor, kısa süreli oyunlar oynuyor veya yürüyor ama çok uzun süre aktif kalmıyor.”\n- Emeklemeye başlamış bebekler\n- Yeni yürümeye başlayan çocuklar (1–2 yaş)\n- Oyunla ilgileniyor ama uzun süre aktif değil",
                "🔸 “Çocuğum yürüyebiliyor, sık sık hareket ediyor, oyun oynuyor, dışarıda koşuyor ve enerjik.”\n- Gün içinde koşma, zıplama gibi hareketler yapıyor\n- Oyuncaklarla aktif şekilde oynuyor\n- Günde en az 3–4 saat aktif zaman geçiriyor",
              ];

              return Column(
                children: [
                  ListTile(
                    leading: Radio<String>(
                      value: secenekler[index],
                      groupValue: _aktiviteDuzeyi,
                      onChanged: (value) {
                        setState(() {
                          _aktiviteDuzeyi = value!;
                        });
                      },
                    ),
                    title: Text(secenekler[index], style: TextStyle(fontSize: 18)),
                    trailing: IconButton(
                      icon: Icon(Icons.help_outline),
                      onPressed: () {
                        setState(() {
                          showInfo[index] = !(showInfo[index] ?? false);
                        });
                      },
                    ),
                  ),
                  if (showInfo[index] == true)
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        aciklamalar[index],
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                ],
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
                style: TextStyle(fontSize: 20),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: Text("Evet"),
                  selected: _alerjiVarMi == "Evet",
                  onSelected: (selected) {
                    setState(() {
                      _alerjiVarMi = "Evet";
                    });
                  },
                ),
                SizedBox(width: 10),
                ChoiceChip(
                  label: Text("Hayır"),
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
                children: [
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
                  "Baharatlara duyarlılık"
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _digerAlerjiController,
                  decoration: InputDecoration(
                    labelText: "Diğer (lütfen belirtiniz)",
                    border: OutlineInputBorder(),
                  ),
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
                style: TextStyle(fontSize: 20),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: Text("Evet"),
                  selected: _hastalikVarMi == "Evet",
                  onSelected: (selected) {
                    setState(() {
                      _hastalikVarMi = "Evet";
                    });
                  },
                ),
                SizedBox(width: 10),
                ChoiceChip(
                  label: Text("Hayır"),
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
                children: [
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
                  "Hipervitaminosis (Aşırı vitamin alımı)"
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _digerHastalikController,
                  decoration: InputDecoration(
                    labelText: "Diğer (lütfen belirtiniz)",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ],
        );

    // >>> BURAYA DİĞER AŞAMALAR EKLENECEK <<<

      default:
        return Text("Tamamlandı");
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
        title: Text("Çocuk Profili Oluştur"),
        centerTitle: true,
      ),
      body: Center(
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
                    ElevatedButton(
                      onPressed: _geriGit,
                      child: Text(
                        "Geri Git",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  if (_aktifAdim > 0)
                    SizedBox(width: 20), // Geri Git ile Devam Et arasında boşluk
                  ElevatedButton(
                    onPressed: () {
                      _asamaVerisiniKaydet();
                      _ileriGit();
                    },
                    child: Text(
                      _aktifAdim < 7 ? "Devam Et" : "Tamamla",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}