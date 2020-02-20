import 'package:json_api/server.dart';
import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:json_api/src/server/request_handler.dart';
import 'package:test/test.dart';

void main() {

  test('Async creation', () {

  });
}

class AsyncCreation implements RequestHandler<Response> {
  @override
  Response createResource(String type, Resource resource) {
    // TODO: implement createResource
    return null;
  }

  @override
  Response fetchResource(
      String type, String id, Map<String, List<String>> queryParameters) {
    // TODO: implement fetchResource
    return null;
  }

  @override
  Response addToRelationship(String type, String id, String relationship,
      Iterable<Identifier> identifiers) {
    return null;
  }

  @override
  Response deleteFromRelationship(String type, String id, String relationship,
      Iterable<Identifier> identifiers) {
    return null;
  }

  @override
  Response deleteResource(String type, String id) {
    return null;
  }

  @override
  Response fetchCollection(
      String type, Map<String, List<String>> queryParameters) {
    return null;
  }

  @override
  Response fetchRelated(String type, String id, String relationship,
      Map<String, List<String>> queryParameters) {
    return null;
  }

  @override
  Response fetchRelationship(String type, String id, String relationship,
      Map<String, List<String>> queryParameters) {
    return null;
  }

  @override
  Response replaceToMany(String type, String id, String relationship,
      Iterable<Identifier> identifiers) {
    return null;
  }

  @override
  Response replaceToOne(
      String type, String id, String relationship, Identifier identifier) {
    return null;
  }

  @override
  Response updateResource(String type, String id, Resource resource) {
    return null;
  }
}
