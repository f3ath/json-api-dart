import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:json_api/src/server/request.dart';

/// Routing defines the design of URLs.
abstract class Routing {
  /// Builds a URI for a resource collection
  Uri collection(String type, {Map<String, String> params});

  /// Builds a URI for a single resource
  Uri resource(String type, String id);

  /// Builds a URI for a related resource
  Uri related(String type, String id, String relationship);

  /// Builds a URI for a relationship object
  Uri relationship(String type, String id, String relationship);

  /// Resolves HTTP request to [JsonAiRequest] object
  Future<JsonApiRequest> resolve(HttpRequest httpRequest);
}

/// StandardRouting implements the recommended URL design schema:
///
/// /photos - for a collection
/// /photos/1 - for a resource
/// /photos/1/relationships/author - for a relationship
/// /photos/1/author - for a related resource
///
/// See https://jsonapi.org/recommendations/#urls
class StandardRouting implements Routing {
  final Uri base;

  StandardRouting(this.base) {
    ArgumentError.checkNotNull(base, 'base');
  }

  collection(String type, {Map<String, String> params}) => base.replace(
      pathSegments: base.pathSegments + [type],
      queryParameters:
          _nonEmpty(CombinedMapView([base.queryParameters, params ?? {}])));

  related(String type, String id, String relationship) =>
      base.replace(pathSegments: base.pathSegments + [type, id, relationship]);

  relationship(String type, String id, String relationship) => base.replace(
      pathSegments:
          base.pathSegments + [type, id, 'relationships', relationship]);

  resource(String type, String id) =>
      base.replace(pathSegments: base.pathSegments + [type, id]);

  Future<JsonApiRequest> resolve(HttpRequest httpRequest) async {
    final body = await httpRequest.transform(utf8.decoder).join();

    final seg = httpRequest.uri.pathSegments;
    switch (seg.length) {
      case 1:
        return CollectionRequest(httpRequest.method, seg[0],
            body: body, params: httpRequest.uri.queryParameters);
      case 2:
        return ResourceRequest(httpRequest.method, seg[0], seg[1], body: body);
      case 3:
        return RelatedRequest(httpRequest.method, seg[0], seg[1], seg[2]);
      case 4:
        if (seg[2] == 'relationships') {
          return RelationshipRequest(httpRequest.method, seg[0], seg[1], seg[3],
              body: body);
        }
    }
    return null; // TODO: replace with a null-object
  }

  Map<K, V> _nonEmpty<K, V>(Map<K, V> map) => map.isEmpty ? null : map;
}
