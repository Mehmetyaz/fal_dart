import 'dart:io' as io;
import 'dart:convert';

class FalImage {
  final String url;
  final int width, height;
  final String contentType;

  FalImage(this.url, this.width, this.height, this.contentType);

  factory FalImage.fromJson(Map<String, dynamic> json) {
    return FalImage(
      json["url"] as String,
      json["width"] as int,
      json["height"] as int,
      json["content_type"] as String,
    );
  }
}

class FalClient {
  FalClient([String? apiKey]) {
    this.apiKey = apiKey ?? io.Platform.environment["FAL_API_KEY"]!;
  }

  late final String apiKey;

  Future<List<FalImage>> run(String app, Map<String, dynamic> options) async {
    final client = io.HttpClient();

    final url = "fal.run/$app".replaceAll("//", "/");

    final res = await client.postUrl(Uri.parse("https://$url"));

    res.headers.contentType = io.ContentType.json;
    res.headers.add("Authorization", "Key $apiKey");
    res.headers.add("Accept", io.ContentType.json.mimeType);
    res.write(jsonEncode(options));
    final response = await res.close();
    final body = await response.transform(utf8.decoder).join();

    if (response.statusCode > 299) {
      throw Exception("Failed to run app: $body");
    }

    final jsonBody = jsonDecode(body);

    return jsonBody["images"]
        .map<FalImage>((e) => FalImage.fromJson(e))
        .toList();
  }
}
