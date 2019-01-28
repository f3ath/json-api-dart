import 'dart:async';

import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/server/query_parameters.dart';

abstract class Controller<T> {
  FutureOr<T> fetchCollection(CollectionRequest request);

//  FutureOr<T> fetchResource(ResourceRequest route);
//
//  FutureOr<T> fetchRelated(RelatedRequest route);
//
//  FutureOr<T> fetchRelationship(RelationshipRequest route);
}

/// Route object
abstract class Request {
  T handleBy<T>(Controller<T> controller);
}

abstract class RequestFactory {
  FutureOr<Request> createRequest(Uri uri, String method);
}

abstract class LinkFactory {
  Link collectionLink(String type, {Map<String, String> params});

  Link resourceLink(String type, String id);

  Link relatedLink(String type, String id, String name);

  Link relationshipLink(String type, String id, String name);
}

/// Route to a resource collection
class CollectionRequest implements Request {
  /// Collection type
  final String type;

  /// Filtering for sparse fieldsets
  final Fields fields;

  /// Pagination
  final Page page;

  /// Sorting
  final Sort sort;

  /// Filtering
  final Filter filter;

  /// Request method
  final String method;

  CollectionRequest(this.type,
      {this.page, this.sort, this.fields, this.filter, this.method}) {
    ArgumentError.checkNotNull(type, 'type');
  }

  T handleBy<T>(Controller<T> controller) => controller.fetchCollection(this);
}
//
///// Route to a resource
//class ResourceRequest implements Request {
//  final String type;
//  final String id;
//
//  /// Request method
//  final String method;
//
//  ResourceRequest(this.type, this.id, {this.method}) {
//    ArgumentError.checkNotNull(type, 'type');
//    ArgumentError.checkNotNull(id, 'id');
//  }
//
//  T handleBy<T>(Controller<T> controller) => controller.fetchResource(this);
//}
//
///// Route to a related object
//class RelatedRequest implements Request {
//  final String type;
//  final String id;
//  final String name;
//
//  /// Request method
//  final String method;
//
//  RelatedRequest(this.type, this.id, this.name, {this.method}) {
//    ArgumentError.checkNotNull(type, 'type');
//    ArgumentError.checkNotNull(id, 'id');
//    ArgumentError.checkNotNull(name, 'name');
//  }
//
//  T handleBy<T>(Controller<T> controller) => controller.fetchRelated(this);
//}
//
///// Route to a relationship
//class RelationshipRequest implements Request {
//  final String type;
//  final String id;
//  final String name;
//
//  /// Request method
//  final String method;
//
//  RelationshipRequest(this.type, this.id, this.name, {this.method}) {
//    ArgumentError.checkNotNull(type, 'type');
//    ArgumentError.checkNotNull(id, 'id');
//    ArgumentError.checkNotNull(name, 'name');
//  }
//
//  T handleBy<T>(Controller<T> controller) => controller.fetchRelationship(this);
//}
