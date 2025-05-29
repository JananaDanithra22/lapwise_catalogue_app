import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';

class AiSuggestionService {
  // TODO: Replace with your complete Gemini API key
  final String apiKey = 'AIzaSyC95H7LtJa_XAJZFZ73NDQsX77LXSSDsmg';

  Future<String> getLaptopComparisonSuggestion(String promptText) async {
    try {
      print('Starting Gemini API call...');
      print('API Key length: ${apiKey.length}');
      print('Prompt length: ${promptText.length}');

      // Validate API key
      if (apiKey.isEmpty || apiKey == 'YOUR_COMPLETE_GEMINI_API_KEY_HERE') {
        return "API key not configured. Please add your Gemini API key.";
      }

      // Check internet connectivity
      try {
        final result = await InternetAddress.lookup(
          'generativelanguage.googleapis.com',
        );
        if (result.isEmpty) {
          return "No internet connection. Please check your network and try again.";
        }
      } on SocketException catch (_) {
        return "No internet connection. Please check your network and try again.";
      }

      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        requestOptions: RequestOptions(),
      );

      // Enhanced prompt with proper Markdown formatting instructions
      final enhancedPrompt = _buildStructuredPrompt(promptText);
      final content = [Content.text(enhancedPrompt)];

      print('Sending request to Gemini...');

      final response = await model.generateContent(content);
      print('Received response from Gemini');
      print('Response text length: ${response.text?.length ?? 0}');

      if (response.text == null || response.text!.isEmpty) {
        return "Unable to generate suggestions at this time. The AI service returned an empty response.";
      }

      return response.text!;
    } on GenerativeAIException catch (e) {
      print('Gemini AI Error: ${e.message}');
      print('Error type: ${e.runtimeType}');

      // Handle specific error types
      if (e.message.contains('API_KEY_INVALID') ||
          e.message.contains('invalid API key')) {
        return "Invalid API key. Please check your Gemini API key configuration.";
      } else if (e.message.contains('QUOTA_EXCEEDED') ||
          e.message.contains('quota')) {
        return "API quota exceeded. Please try again later or check your billing.";
      } else if (e.message.contains('BLOCKED') ||
          e.message.contains('safety')) {
        return "Content was blocked by safety filters. Try rephrasing your request.";
      } else if (e.message.contains('PERMISSION_DENIED')) {
        return "Permission denied. Please check your API key permissions.";
      } else if (e.message.contains('NOT_FOUND')) {
        return "API endpoint not found. Please check your configuration.";
      } else {
        return "AI service error: ${e.message}";
      }
    } on SocketException catch (e) {
      print('Network error: $e');
      return "Network connection failed. Please check your internet connection and try again.";
    } on HttpException catch (e) {
      print('HTTP error: $e');
      return "HTTP request failed. Please try again.";
    } on FormatException catch (e) {
      print('Format error: $e');
      return "Invalid response format from AI service.";
    } catch (e) {
      print('General error: $e');
      print('Error type: ${e.runtimeType}');
      return "Sorry, I encountered an unexpected error while analyzing your laptops. Please try again.";
    }
  }

  // Build a structured prompt for concise comparisons with proper Markdown formatting
  String _buildStructuredPrompt(String originalPrompt) {
    return """
Compare the following laptops and provide a CONCISE response using proper Markdown formatting:

$originalPrompt

IMPORTANT INSTRUCTIONS:
- Keep the response under 500 words total
- Use proper Markdown formatting for lists (use - or * for bullet points)
- Focus on key differences only
- Provide a brief recommendation at the end

FORMAT YOUR RESPONSE EXACTLY LIKE THIS (using proper Markdown):

# 🔍 QUICK COMPARISON

## Key Specifications:
- **Processor:** [Brief comparison]
- **RAM & Storage:** [Brief comparison]
- **Display:** [Brief comparison]
- **Graphics:** [Brief comparison]
- **Battery:** [Brief comparison]
- **Price:** [Brief comparison]

## Main Differences:
- [Most important difference 1]
- [Most important difference 2]  
- [Most important difference 3]

## Best For:
- **Laptop 1:** [Primary use case]
- **Laptop 2:** [Primary use case]

## 💡 Recommendation:
[One sentence recommendation based on typical needs]

Keep each point to 1-2 lines maximum. Focus on practical differences that matter to buyers.
""";
  }

  // Alternative method for getting quick specs comparison only
  Future<String> getQuickSpecsComparison(String laptopSpecs) async {
    final quickPrompt = """
Analyze these laptop specifications and provide ONLY a structured comparison using proper Markdown formatting:

$laptopSpecs

Respond with EXACTLY this format (using proper Markdown):

## SPECS COMPARISON

| Feature | Laptop 1 | Laptop 2 |
|---------|----------|----------|
| Processor | [brief] | [brief] |
| RAM | [brief] | [brief] |
| Storage | [brief] | [brief] |
| Display | [brief] | [brief] |
| Graphics | [brief] | [brief] |
| Battery | [brief] | [brief] |
| Price | [brief] | [brief] |

**Winner:** [Which laptop is better overall and why - 1 sentence]
""";

    return getLaptopComparisonSuggestion(quickPrompt);
  }

  // Method for getting pros and cons summary
  Future<String> getProsConsComparison(String laptopDetails) async {
    final prosConsPrompt = """
Compare these laptops and provide ONLY pros and cons using proper Markdown formatting:

$laptopDetails

Format response EXACTLY like this (using proper Markdown):

## LAPTOP 1

### ✅ Pros:
- [Advantage 1]
- [Advantage 2]
- [Advantage 3]

### ❌ Cons:
- [Disadvantage 1]
- [Disadvantage 2]

## LAPTOP 2

### ✅ Pros:
- [Advantage 1]
- [Advantage 2]
- [Advantage 3]

### ❌ Cons:
- [Disadvantage 1]
- [Disadvantage 2]

**Bottom Line:** [One sentence verdict]
""";

    return getLaptopComparisonSuggestion(prosConsPrompt);
  }

  // Method to validate API key format
  bool isValidApiKey(String key) {
    // Gemini API keys typically start with "AIza" and are 39 characters long
    return key.startsWith('AIza') && key.length == 39;
  }

  // Method to test API connection
  Future<bool> testConnection() async {
    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      final content = [Content.text('Hello')];
      final response = await model.generateContent(content);
      return response.text != null && response.text!.isNotEmpty;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }

  // Method to list available models
  Future<void> listAvailableModels() async {
    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      // This is just to test - actual model listing requires different API calls
      print('Using model: gemini-1.5-flash');

      // You can also try these models:
      print('Available models to try:');
      print('- gemini-1.5-flash (recommended)');
      print('- gemini-1.5-pro');
      print('- gemini-1.0-pro');
    } catch (e) {
      print('Error listing models: $e');
    }
  }
}
