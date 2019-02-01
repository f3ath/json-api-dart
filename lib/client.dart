import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:json_api/document.dart';

class JsonApiClient {
  JsonApiClient();

  Future<CollectionDocument> fetchCollection(Uri uri) async {
    final res = await http.Client().get(uri);
    print(res.body);
    if (res.statusCode == 404) throw NotFoundException();
    final doc = CollectionDocument.fromJson(json.decode(res.body));
    return doc;
  }

  Future<ResourceDocument> fetchResource(Uri uri) async {
    final res = await http.Client().get(uri);
    if (res.statusCode == 404) throw NotFoundException();
    final doc = ResourceDocument.fromJson(json.decode(res.body));
    return doc;
  }
}

class NotFoundException implements Exception {

}