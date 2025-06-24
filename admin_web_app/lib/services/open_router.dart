import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OpenRouter {
  /// Replace this with your actual OpenRouter API key
  String openRouterApiKey =
      "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";

  /// Optional but recommended for OpenRouter rankings
  String yourSiteUrl = "<YOUR_SITE_URL>";
  String yourSiteName = "<YOUR_SITE_NAME>";

  Future<String> fetchTranslationSuggestion({
    required String englishText,
    required String targetLanguage,
  }) async {
    final url = Uri.parse("https://openrouter.ai/api/v1/chat/completions");

    final headers = {
      "Authorization": "Bearer $openRouterApiKey",
      "Content-Type": "application/json",
      "HTTP-Referer": "",
      "X-Title": "",
    };

    final prompt =
        "Translate the following English text to $targetLanguage:\n\n$englishText and give me the result in json format";

    final body = jsonEncode({
      "model":
          "openai/gpt-4o", // Or use another free one like "openai/gpt-3.5-turbo"
      "max_tokens": 512,
      "messages": [
        {"role": "user", "content": prompt}
      ]
    });
    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["choices"][0]["message"]["content"].toString().trim();
      } else {
        throw Exception(
            "OpenRouter API failed: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      debugPrint("OpenRouter API failed: $e");
      return "";
    }
  }
}
