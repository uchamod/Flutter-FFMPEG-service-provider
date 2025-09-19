import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ElevanlabServices {
  // final apiKey = dotenv.env['ELEVAN_LABS_API'] ?? "";
  final baseUrl = "https://api.elevenlabs.io/v1";
  final http.Client _client = http.Client();
  //generate music effect
  Future<String?> generateMusic({
    required String prompt,
    required int duration,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse("https://api.elevenlabs.io/v1/music"),
        headers: {
          "Content-Type": "application/json",
          "xi-api-key": "sk_af8f7283613f767af49d6bb1623441592d31489942271cec",
        },
        body: jsonEncode({"prompt": prompt, "music_length_ms": duration}),
      );

      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final filePath =
            "${dir.path}/elevan_${DateTime.now().millisecondsSinceEpoch}.mp3";
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        print("✅ Music generated and saved: $filePath");
        return filePath;
      } else {
        print("❌ Failed: ${response.statusCode}, ${response.body}");
        return null;
      }
    } catch (err) {
      print("music genaration failed $err");
      return null;
    }
  }
}

// curl -X POST "https://api.elevenlabs.io/v1/music?output_format=mp3_44100_128" \
//      -H "xi-api-key: xi-api-key" \
//      -H "Content-Type: application/json" \
//      -d '{
//   "prompt": "a high temperature latin music beat mix with classical guitar music",
//   "music_length_ms": 15
// }'
// curl -X POST "https://api.elevenlabs.io/v1/music?output_format=mp3_44100_128" \
//      -H "xi-api-key: abac8e17ae22b70612293a0e6600304cb0a1b359d1b66f373b57831829ed4549" \
//      -H "Content-Type: application/json" \
//      -d '{
//   "prompt": "a high temperature latin music beat mix with classical guitar music",
//   "music_length_ms": 15000
// }'
