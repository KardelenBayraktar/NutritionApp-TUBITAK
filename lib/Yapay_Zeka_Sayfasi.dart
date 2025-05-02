import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class AIPage extends StatefulWidget {
  @override
  _AIPageState createState() => _AIPageState();
}

class _AIPageState extends State<AIPage> {
  List<Map<String, String>> messages = [
    {
      "sender": "bot",
      "text": "Merhabalar, ben Beslenme Asistanın 🤖 Size nasıl yardımcı olabilirim?"
    }
  ];
  TextEditingController _controller = TextEditingController();

  final String azureApiKey = "64WPauhkMzxYP6Yf3gSzUzbhCjby51YgjQpi0CBOl3ByzPkhICG5JQQJ99BDACHYHv6XJ3w3AAAAACOGq9QM";
  final String azureEndpoint = "https://salih-ma2r5l7j-eastus2.openai.azure.com/openai/deployments/gpt-4.1/chat/completions?api-version=2025-01-01-preview";

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kamera izni verilmedi.')),
        );
        return;
      }
    }

    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _selectedImage = File(pickedFile.path);
      setState(() {
        messages.add({
          "sender": "user",
          "text": "📷 Bir fotoğraf gönderdiniz. Lütfen açıklamasını yeni bir mesaj olarak gönderiniz..."
        });
      });
      _controller.text = "";
    }
  }

  Future<String> _convertImageToBase64(File imageFile) async {
    List<int> imageBytes = await imageFile.readAsBytes();
    return base64Encode(imageBytes);
  }

  void _sendMessage() async {
    if (_controller.text.trim().isNotEmpty) {
      String userMessage = _controller.text.trim();

      setState(() {
        messages.add({"sender": "user", "text": userMessage});
        _controller.clear();
      });

      String aiResponse = await _getAIResponse();

      setState(() {
        messages.add({"sender": "bot", "text": aiResponse});
      });
    }
  }

  Future<String> _getAIResponse() async {
    try {
      List<Map<String, dynamic>> chatMessages = [
        {"role": "system", "content": "Sen bir yardımcı asistansın."}
      ];

      for (var msg in messages) {
        if (msg["sender"] == "user" && _selectedImage != null) {
          String base64Image = await _convertImageToBase64(_selectedImage!);
          chatMessages.add({
            "role": "user",
            "content": [
              {"type": "text", "text": msg["text"]!},
              {
                "type": "image_url",
                "image_url": {
                  "url": "data:image/jpeg;base64,$base64Image",
                }
              }
            ]
          });
          _selectedImage = null; // sadece ilk resim için
        } else {
          chatMessages.add({
            "role": msg["sender"] == "user" ? "user" : "assistant",
            "content": msg["text"]!,
          });
        }
      }

      var response = await http.post(
        Uri.parse(azureEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'api-key': azureApiKey,
        },
        body: jsonEncode({
          "messages": chatMessages,
          "temperature": 0.7,
          "max_tokens": 1000,
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'];
      } else {
        print("Hata kodu: ${response.statusCode}");
        print("Hata mesajı: ${response.body}");
        return "Üzgünüm, şu anda yanıt veremiyorum 😔";
      }
    } catch (e) {
      print("İstek hatası: $e");
      return "Bir hata oluştu, lütfen tekrar deneyin.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFF3F6),
      appBar: AppBar(
        title: Text("💬 AI Asistan"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                bool isUser = messages[index]["sender"] == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.deepPurpleAccent : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                        bottomLeft: isUser ? Radius.circular(16) : Radius.circular(0),
                        bottomRight: isUser ? Radius.circular(0) : Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      messages[index]["text"]!,
                      style: TextStyle(
                        fontSize: 16,
                        color: isUser ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Mesajınızı yazın...",
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.camera_alt, color: Colors.grey),
            onPressed: _pickImage,
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.deepPurple),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}



