import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/ai_config.dart';

class AiService {
  late final GenerativeModel _model;

  AiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: AiConfig.apiKey,
    );
  }

  Future<String> getMbtiAnalysis(String type, String title, String description) async {
    final prompt = '''
    You are an expert MBTI personality analyst. The user has tested as $type ($title).
    
    Here is a brief description:
    $description
    
    Based on this, provide a personalized analysis covering:
    1. **Key Strengths**: 3 bullet points.
    2. **Potential Weaknesses**: 3 bullet points.
    3. **Growth Advice**: 1 short paragraph.
    
    Keep the tone encouraging, insightful, and professional. Format with Markdown.
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? 'Unable to generate analysis at this time.';
    } catch (e) {
      return 'Error analyzing results: $e. Please check your API Key in lib/config/ai_config.dart';
    }
  }
}
