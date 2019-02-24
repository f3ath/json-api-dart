import 'dart:async';

import 'package:json_api/client.dart';
import 'package:json_api/src/transport/collection_document.dart';
import 'package:json_api/src/transport/relationship.dart';
import 'package:json_api/src/transport/resource_envelope.dart';

class CarsClient {
  final Client c;

  CarsClient(this.c);

  Future<CollectionDocument> fetchCollection(String type) async {
    final res =
        await c.fetchCollection(Uri.parse('http://localhost:8080/$type'));
    return res.document;
  }

  Future<ToOne> fetchToOne(String type, String id, String name) async {
    final rel = await c.fetchToOne(
        Uri.parse('http://localhost:8080/$type/$id/relationships/$name'));
    return rel.document;
  }

  Future<ToMany> fetchToMany(String type, String id, String name) async {
    final rel = await c.fetchToMany(
        Uri.parse('http://localhost:8080/$type/$id/relationships/$name'));
    return rel.document;
  }

  Future<ResourceEnvelope> fetchResource(String type, String id) async {
    final rel =
        await c.fetchResource(Uri.parse('http://localhost:8080/$type/$id'));
    return rel.document.resourceEnvelope;
  }
}
