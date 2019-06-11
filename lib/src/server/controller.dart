import 'dart:async';

import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:json_api/src/server/request.dart';
import 'package:json_api/src/server/response.dart';


abstract class Controller {
  bool supportsType(String type);

  FutureOr<Response> fetchCollection(
      FetchCollection request, Map<String, List<String>> query);

  FutureOr<Response> fetchResource(
      FetchResource request, Map<String, List<String>> query);

  FutureOr<Response> fetchRelated(
      FetchRelated request, Map<String, List<String>> query);

  FutureOr<Response> fetchRelationship(
      FetchRelationship request, Map<String, List<String>> query);

  FutureOr<Response> deleteResource(DeleteResource request);

  FutureOr<Response> createResource(CreateResource request, Resource resource);

  FutureOr<Response> updateResource(UpdateResource request, Resource resource);

  FutureOr<Response> replaceToOne(
      UpdateRelationship request, Identifier identifier);

  FutureOr<Response> replaceToMany(
      UpdateRelationship request, List<Identifier> identifiers);

  FutureOr<Response> addToMany(AddToMany request, List<Identifier> identifiers);
}
