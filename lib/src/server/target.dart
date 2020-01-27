import 'package:json_api/document.dart';
import 'package:json_api/src/server/json_api_request.dart';
import 'package:json_api/src/server/json_api_response.dart';
import 'package:json_api/uri_design.dart';

/// The target of a JSON:API request URI. The URI target and the request method
/// uniquely identify the meaning of the JSON:API request.
abstract class Target {
  /// Returns the request corresponding to the request [method].
  JsonApiRequest getRequest(String method);

  /// Returns the target of the [url] according to the [design]
  static Target of(Uri uri, UriDesign design) {
    final builder = _Builder();
    design.matchTarget(uri, builder);
    return builder.target ?? _Invalid(uri);
  }
}

class _Builder implements OnTargetMatch {
  Target target;

  @override
  void collection(String type) {
    target = _Collection(type);
  }

  @override
  void resource(String type, String id) {
    target = _Resource(type, id);
  }

  @override
  void related(String type, String id, String rel) {
    target = _Related(type, id, rel);
  }

  @override
  void relationship(String type, String id, String rel) {
    target = _Relationship(type, id, rel);
  }
}

/// The target of a URI referring a resource collection
class _Collection implements Target {
  /// Resource type
  final String type;

  const _Collection(this.type);

  @override
  JsonApiRequest getRequest(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return JsonApiRequest.fetchCollection(type);
      case 'POST':
        return JsonApiRequest.createResource(type);
      default:
        return _methodNoAllowed(['GET', 'POST']);
    }
  }
}

/// The target of a URI referring to a single resource
class _Resource implements Target {
  /// Resource type
  final String type;

  /// Resource id
  final String id;

  const _Resource(this.type, this.id);

  @override
  JsonApiRequest getRequest(String method) {
    switch (method.toUpperCase()) {
      case 'DELETE':
        return JsonApiRequest.deleteResource(type, id);
      case 'GET':
        return JsonApiRequest.fetchResource(type, id);
      case 'PATCH':
        return JsonApiRequest.updateResource(type, id);
      default:
        return _methodNoAllowed(['DELETE', 'GET', 'PATCH']);
    }
  }
}

/// The target of a URI referring a related resource or collection
class _Related implements Target {
  /// Resource type
  final String type;

  /// Resource id
  final String id;

  /// Relationship name
  final String relationship;

  const _Related(this.type, this.id, this.relationship);

  @override
  JsonApiRequest getRequest(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return JsonApiRequest.fetchRelated(type, id, relationship);
      default:
        return _methodNoAllowed(['GET']);
    }
  }
}

/// The target of a URI referring a relationship
class _Relationship implements Target {
  /// Resource type
  final String type;

  /// Resource id
  final String id;

  /// Relationship name
  final String relationship;

  const _Relationship(this.type, this.id, this.relationship);

  @override
  JsonApiRequest getRequest(String method) {
    switch (method.toUpperCase()) {
      case 'DELETE':
        return JsonApiRequest.deleteFromRelationship(type, id, relationship);
      case 'GET':
        return JsonApiRequest.fetchRelationship(type, id, relationship);
      case 'PATCH':
        return JsonApiRequest.updateRelationship(type, id, relationship);
      case 'POST':
        return JsonApiRequest.addToRelationship(type, id, relationship);
      default:
        return _methodNoAllowed(['DELETE', 'GET', 'PATCH', 'POST']);
    }
  }
}

/// Request URI target which is not recognized by the URL Design.
class _Invalid implements Target {
  final Uri uri;

  const _Invalid(this.uri);

  @override
  JsonApiRequest getRequest(String method) =>
      JsonApiRequest.predefinedResponse(JsonApiResponse.notFound([
        JsonApiError(
            status: '404',
            title: 'Not Found',
            detail: 'The requested URL does exist on the server')
      ]));
}

JsonApiRequest _methodNoAllowed(Iterable<String> allow) =>
    JsonApiRequest.predefinedResponse(JsonApiResponse.methodNotAllowed([
      JsonApiError(
          status: '405',
          title: 'Method Not Allowed',
          detail: 'Allowed methods: ${allow.join(', ')}')
    ], allow: allow));
