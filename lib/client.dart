import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:json_api/document.dart';

class JsonApiClient {
  JsonApiClient();

  Future<CollectionDocument> fetchCollection(String url) async {
    final res = await http.Client().get(url);
    if (res.statusCode == 404) throw NotFoundException();
    final doc = CollectionDocument.fromJson(json.decode(res.body));
    return doc;
  }
}

class NotFoundException implements Exception {

}