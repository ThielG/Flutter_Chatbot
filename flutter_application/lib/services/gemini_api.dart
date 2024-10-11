import 'package:google_generative_ai/google_generative_ai.dart';

getResponse(question) async {
  final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: 'yourApiKEY',
  );

  final prompt = question;
  final content = [Content.text(prompt)];
  final response = await model.generateContent(content);

  return response.text;
}
