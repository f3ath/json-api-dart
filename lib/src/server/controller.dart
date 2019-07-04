import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:json_api/src/server/query/query.dart';
import 'package:json_api/src/server/response.dart';
import 'package:json_api/src/server/target.dart';

abstract class Controller {
  FutureOr<Response> fetchCollection(CollectionTarget target, Query query);

  FutureOr<Response> fetchResource(ResourceTarget target, Query query);

  FutureOr<Response> fetchRelated(RelationshipTarget target, Query query);

  FutureOr<Response> fetchRelationship(RelationshipTarget target, Query query);

  FutureOr<Response> deleteResource(ResourceTarget target);

  FutureOr<Response> createResource(CollectionTarget target, Resource resource);

  FutureOr<Response> updateResource(ResourceTarget target, Resource resource);

  FutureOr<Response> replaceToOne(
      RelationshipTarget target, Identifier identifier);

  FutureOr<Response> replaceToMany(
      RelationshipTarget target, List<Identifier> identifiers);

  FutureOr<Response> addToMany(
      RelationshipTarget target, List<Identifier> identifiers);
}
