import 'package:firebase_ai/firebase_ai.dart';

class AIService {
  // Initialize the Gemini 1.5 Flash model
  final _model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-1.5-flash', // Fast and capable model
  );

  /// Sends a prompt to the AI model and returns the generated response.
  ///
  /// [promptText] is the question or instruction for the AI.
  Future<String> getResponse(String promptText) async {
    try {
      final prompt = [Content.text(promptText)];
      final response = await _model.generateContent(prompt);

      if (response.text != null) {
        return response.text!;
      } else {
        return 'Error: No response from AI model.';
      }
    } catch (e) {
      print('Error calling AI model: $e');
      return 'An error occurred while processing your request.';
    }
  }
}
