import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:json_api/document.dart';

class JsonApiClient implements DocumentClient {
  JsonApiClient();

  Future<CollectionDocument> fetchCollection(Uri uri) async {
    final res = await _fetch(uri);
    return CollectionDocument.fromJson(json.decode(res.body));
  }

  Future<ResourceDocument> fetchResource(Uri uri) async {
    final res = await _fetch(uri);
//    print(res.body);
    return ResourceDocument.fromJson(json.decode(res.body));
  }

  Future<Relationship> fetchRelationship(Uri uri) async {
    final res = await _fetch(uri);
//    print(res.body);
    return Relationship.fromJson(json.decode(res.body));
  }

  Future<http.Response> _fetch(Uri uri) async {
//    print('Fetching $uri');
    final res = await http.Client().get(uri);
    if (res.statusCode == 404) throw NotFoundException();
    return res;
  }
}

class NotFoundException implements Exception {}
