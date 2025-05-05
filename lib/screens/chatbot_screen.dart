// Change this import
// from: import 'package:chatbot/backend_services/chatbot.dart';
// to:
import 'package:chatbot/backend_services/gemini_service.dart';
import 'package:chatbot/screens/signin_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatbotScreen extends StatefulWidget {
  final String username;

  const ChatbotScreen({super.key, required this.username});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];

  // Change this line
  // from: final BackendService _backendService = BackendService();
  // to:
  final GeminiService _backendService = GeminiService();

  @override
  void initState() {
    super.initState();
    _messages.add({
      'isUser': false,
      'text':
          "👋 Hey ${widget.username}, Welcome to 'ShaktiAI'!\nHow can I assist you today?",  // Changed from ChatterAI
    });
  }

  // Function to send the user's message and get a response
  void sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'isUser': true, 'text': text});
      _messages.add({'isUser': false, 'text': "🤖 Gemini is thinking..."});
      _controller.clear();
    });

    _scrollToBottom();

    // Fetching response from Gemini model via BackendService.....start
    String response = await _backendService.getResponse(text);

    setState(() {
      // Replace the last bot message (thinking...) with the actual response
      _messages[_messages.length - 1] = {'isUser': false, 'text': response};
    });

    _scrollToBottom(); //end
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Changed from light color to dark
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes back button
        title: const Text("💬 ShaktiAI"),  // Changed from ChatterAI
        backgroundColor: const Color(0xFF1E1E1E), // Changed from purple to dark gray
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    "Logged out successfully!",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );

              // Navigate to the login screen and replace the current screen
              Future.delayed(const Duration(seconds: 1), () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SigninScreen(),
                  ), // Adjust according to your login screen class
                );
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['isUser'] ?? false;
                return ChatBubble(text: msg['text'], isUser: isUser);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white), // Changed text color to white
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      hintStyle: const TextStyle(color: Colors.grey), // Changed hint color to grey
                      filled: true,
                      fillColor: const Color(0xFF2C2C2C), // Changed input background to dark gray
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none, // Removed border
                      ),
                    ),
                    // Add these lines to handle Enter key press
                    onFieldSubmitted: (value) {
                      sendMessage();
                    },
                    textInputAction: TextInputAction.send,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF0D47A1), // Changed from purple to dark blue
                  child: IconButton(
                    onPressed: sendMessage,
                    icon: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatBubble({super.key, required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF0D47A1) : const Color(0xFF2C2C2C), // Changed colors to blue and dark gray
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
