import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  late final GenerativeModel _model;
  
  factory GeminiService() {
    return _instance;
  }

  GeminiService._internal() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('Gemini API key not found. Please add it to your .env file.');
    }
    _model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey); // Change model name here
  }

  Future<String> getResponse(String prompt) async {
    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? 'Sorry, I couldn\'t generate a response.';
    } catch (e) {
      return 'Error: $e';
    }
  }
}