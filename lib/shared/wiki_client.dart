import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

abstract class Classic {
  static Future<List<String>> getRandomEntityTitles([int amount = 10]) async {
    final String url = "https://en.wikipedia.org/w/api.php?action=query&format=json&list=random&rnnamespace=0&rnlimit=$amount";
    final Map map = JSON.decode(await http.read(url));
    return (map['query']['random'] as List).map((Map map) => map['title'] ).toList();
  }
}

abstract class Restful {
  static Future<Map> getEntity(String title) async {
    final url = "https://en.wikipedia.org/api/rest_v1/page/mobile-sections/${title}";
    return JSON.decode(await http.read(url));
  }
}
