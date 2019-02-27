import 'dart:async';

import 'package:json_api/client.dart';
import 'package:json_api/src/transport/collection_document.dart';
import 'package:json_api/src/transport/relationship.dart';
import 'package:json_api/src/transport/resource_object.dart';

class CarsClient {
  final JsonApiClient c;
  final _base = Uri.parse('http://localhost:8080');

  CarsClient(this.c);

  Future<CollectionDocument> fetchCollection(String type) async {
    final response = await c.fetchCollection(_base.replace(path: '/$type'));
    return response.document;
  }

  Future<ToOne> fetchToOne(String type, String id, String name) async {
    final response = await c
        .fetchToOne(_base.replace(path: '/$type/$id/relationships/$name'));
    return response.document;
  }

  Future<ToMany> fetchToMany(String type, String id, String name) async {
    final response = await c
        .fetchToMany(_base.replace(path: '/$type/$id/relationships/$name'));
    return response.document;
  }

  Future<ResourceObject> fetchResource(String type, String id) async {
    final response = await c.fetchResource(_base.replace(path: '/$type/$id'));
    return response.document.resourceObject;
  }
}
