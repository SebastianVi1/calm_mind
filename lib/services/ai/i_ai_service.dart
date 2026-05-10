import 'dart:async';

/// Interface for AI services to allow easy switching between different providers (e.g., DeepSeek, Gemini, OpenAI)
abstract class IAIService {
  /// Sends a message to the AI and returns a single response
  Future<String> sendMessage(String message);

  /// Sends a message to the AI and returns a stream of responses for real-time UI updates
  Stream<String> sendMessageStream(String message);

  /// Clears the conversation history
  void clearHistory();

  /// One-off content generation without conversation history.
  /// [systemPrompt] sets the AI's role and instructions.
  /// [userPrompt] is the specific generation request.
  /// Returns the raw text response.
  Future<String> generateContent({
    required String systemPrompt,
    required String userPrompt,
    int maxTokens = 2000,
  });
}
