import 'package:json_api/document.dart';
import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:json_api/src/server/json_api_request.dart';

abstract class JsonApiController<Request extends JsonApiRequest, Response> {
  Response fetchCollection(String type, Request request);

  Response fetchResource(String type, String id, Request request);

  Response fetchRelated(
      String type, String id, String relationship, Request request);

  Response fetchRelationship(
      String type, String id, String relationship, Request request);

  Response deleteResource(String type, String id, Request request);

  Response createResource(String type, Resource resource, Request request);

  Response updateResource(
      String type, String id, Resource resource, Request request);

  Response replaceToOne(String type, String id, String relationship,
      Identifier identifier, Request request);

  Response replaceToMany(String type, String id, String relationship,
      List<Identifier> identifiers, Request request);

  Response addToMany(String type, String id, String relationship,
      List<Identifier> identifiers, Request request);
}
