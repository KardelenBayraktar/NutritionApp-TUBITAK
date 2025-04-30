import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class GelisimTakibiSayfasi extends StatefulWidget {
  @override
  _GelisimTakibiSayfasiState createState() => _GelisimTakibiSayfasiState();
}

class _GelisimTakibiSayfasiState extends State<GelisimTakibiSayfasi> {
  double boy = 130; // cm
  double kilo = 30; // kg
  List<int> kaloriVerileri = [1500, 1600, 1400, 1700, 1550, 1650, 1580];

  TextEditingController boyController = TextEditingController();
  TextEditingController kiloController = TextEditingController();

  final days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
  int selectedIndex = 0;

  Map<String, Map<String, int>> gunlukBesinVerileri = {
    'Pzt': {'Karbonhidrat': 200, 'Şeker': 40, 'Yağ': 60, 'Protein': 70},
    'Sal': {'Karbonhidrat': 180, 'Şeker': 30, 'Yağ': 50, 'Protein': 65},
    'Çar': {'Karbonhidrat': 190, 'Şeker': 35, 'Yağ': 55, 'Protein': 60},
    'Per': {'Karbonhidrat': 210, 'Şeker': 45, 'Yağ': 65, 'Protein': 75},
    'Cum': {'Karbonhidrat': 220, 'Şeker': 50, 'Yağ': 70, 'Protein': 80},
    'Cmt': {'Karbonhidrat': 230, 'Şeker': 55, 'Yağ': 75, 'Protein': 85},
    'Paz': {'Karbonhidrat': 240, 'Şeker': 60, 'Yağ': 80, 'Protein': 90},
  };

  double hesaplaBMI() {
    double boyMetre = boy / 100;
    return kilo / pow(boyMetre, 2);
  }

  @override
  void initState() {
    super.initState();
    boyController.text = boy.toString();
    kiloController.text = kilo.toString();

    int todayIndex = (DateTime.now().weekday % 7); // Paz = 0, Pzt = 1, ...
    int startIndex = todayIndex - 5;
    if (startIndex < 0) startIndex += 7;
    selectedIndex = 0; // varsayılan: ilk gösterilen gün
  }

  @override
  void dispose() {
    boyController.dispose();
    kiloController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double bmi = hesaplaBMI();

    int todayIndex = (DateTime.now().weekday % 7);
    int startIndex = todayIndex - 5;
    if (startIndex < 0) startIndex += 7;

    List<int> last5DaysCalories = List.generate(5, (index) {
      int idx = (startIndex + index) % 7;
      return kaloriVerileri[idx];
    });

    List<String> last5DaysNames = List.generate(5, (index) {
      int idx = (startIndex + index) % 7;
      return days[idx];
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Gelişim Takibi'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Fiziksel Ölçümler",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green[800]),
            ),
            SizedBox(height: 10),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: boyController,
                        decoration: InputDecoration(labelText: 'Boy (cm)'),
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          setState(() {
                            boy = double.tryParse(val) ?? boy;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: kiloController,
                        decoration: InputDecoration(labelText: 'Kilo (kg)'),
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          setState(() {
                            kilo = double.tryParse(val) ?? kilo;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            Row(
              children: [
                Text(
                  'Vücut Kitle İndeksi (BMI): ',
                  style: TextStyle(fontSize: 16),
                ),
                Chip(
                  label: Text(
                    bmi.toStringAsFixed(2),
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  backgroundColor: Colors.green,
                ),
              ],
            ),
            SizedBox(height: 32),

            Text(
              "Son 7 Günlük Kalori Takibi",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green[800]),
            ),
            SizedBox(height: 10),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      minY: 1300,
                      maxY: 1800,
                      borderData: FlBorderData(show: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 100,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  last5DaysNames[value.toInt()],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: value.toInt() == todayIndex ? Colors.green : Colors.black,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          spots: List.generate(
                            last5DaysCalories.length,
                                (index) => FlSpot(index.toDouble(), last5DaysCalories[index].toDouble()),
                          ),
                          barWidth: 3,
                          color: Colors.orange,
                          dotData: FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 32),

            Text(
              "Kalori Tablosu",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green[800]),
            ),
            SizedBox(height: 10),

            /// Gün seçimi ve makro bilgisi
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (index) {
                        String dayName = last5DaysNames[index];
                        bool isSelected = index == selectedIndex;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndex = index;
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 4),
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.green.shade100 : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? Colors.green : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    dayName,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      fontSize: 14,
                                      color: isSelected ? Colors.green[900] : Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '${last5DaysCalories[index]} kcal',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 16),

                    /// Seçilen günün makro değerleri
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: gunlukBesinVerileri[last5DaysNames[selectedIndex]]!.entries.map((e) {
                        return Column(
                          children: [
                            Text(
                              e.key,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('${e.value}g'),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
