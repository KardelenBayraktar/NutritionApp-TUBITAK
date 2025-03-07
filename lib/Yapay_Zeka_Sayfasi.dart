import 'package:flutter/material.dart';

class AIPage extends StatefulWidget {
  const AIPage({super.key});

  @override
  _AIPageState createState() => _AIPageState();
}

class _AIPageState extends State<AIPage> {
  List<Map<String, String>> messages = [
    {"sender": "bot", "text": "Merhabalar, ben Asistan. Sizlere nasıl yardımcı olabilirim?"}
  ];
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    if (_controller.text.trim().isNotEmpty) {
      setState(() {
        messages.add({"sender": "user", "text": _controller.text});
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("AI Asistan")),
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
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.green[200] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(messages[index]["text"]!, style: TextStyle(fontSize: 16)),
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
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))
      ]),
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
            onPressed: () {
              // Şu an boş, ancak ileride kamera açma işlevi eklenebilir.
            },
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.green),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}