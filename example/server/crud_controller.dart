import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/server.dart';
import 'package:shelf/shelf.dart';

class CRUDController implements Controller<Request> {
  final String Function() generateId;

  final store = <String, Map<String, Resource>>{};

  CRUDController(this.generateId);

  @override
  FutureOr<JsonApiResponse> createResource(
      Request request, String type, Resource resource) {
    if (resource.type != type) {
      return JsonApiResponse.conflict(
          [JsonApiError(detail: 'Incompatible type')]);
    }
    final repo = _repo(type);
    if (resource.id != null) {
      if (repo.containsKey(resource.id)) {
        return JsonApiResponse.conflict(
            [JsonApiError(detail: 'Resource already exists')]);
      }
      repo[resource.id] = resource;
      return JsonApiResponse.noContent();
    }
    final id = generateId();
    repo[id] = resource.replace(id: id);
    return JsonApiResponse.resourceCreated(repo[id]);
  }

  @override
  FutureOr<JsonApiResponse> fetchResource(
      Request request, String type, String id) {
    final repo = _repo(type);
    if (repo.containsKey(id)) {
      return JsonApiResponse.resource(repo[id]);
    }
    return JsonApiResponse.notFound(
        [JsonApiError(detail: 'Resource not found', status: '404')]);
  }

  @override
  FutureOr<JsonApiResponse> addToRelationship(Request request, String type,
      String id, String relationship, Iterable<Identifier> identifiers) {
    final resource = _repo(type)[id];
    final ids = [...resource.toMany[relationship], ...identifiers];
    _repo(type)[id] =
        resource.replace(toMany: {...resource.toMany, relationship: ids});
    return JsonApiResponse.toMany(type, id, relationship, ids);
  }

  @override
  FutureOr<JsonApiResponse> deleteFromRelationship(Request request, String type,
      String id, String relationship, Iterable<Identifier> identifiers) {
    final resource = _repo(type)[id];
    final rel = [...resource.toMany[relationship]];
    rel.removeWhere(identifiers.contains);
    final toMany = {...resource.toMany};
    toMany[relationship] = rel;
    _repo(type)[id] = resource.replace(toMany: toMany);

    return JsonApiResponse.toMany(type, id, relationship, rel);
  }

  @override
  FutureOr<JsonApiResponse> deleteResource(
      Request request, String type, String id) {
    final repo = _repo(type);
    if (!repo.containsKey(id)) {
      return JsonApiResponse.notFound(
          [JsonApiError(detail: 'Resource not found')]);
    }
    final resource = repo[id];
    repo.remove(id);
    final relationships = {...resource.toOne, ...resource.toMany};
    if (relationships.isNotEmpty) {
      return JsonApiResponse.meta({'relationships': relationships.length});
    }
    return JsonApiResponse.noContent();
  }

  @override
  FutureOr<JsonApiResponse> fetchCollection(Request request, String type) {
    final repo = _repo(type);
    return JsonApiResponse.collection(repo.values);
  }

  @override
  FutureOr<JsonApiResponse> fetchRelated(
      Request request, String type, String id, String relationship) {
    final resource = _repo(type)[id];
    if (resource == null) {
      return JsonApiResponse.notFound(
          [JsonApiError(detail: 'Resource not found')]);
    }
    if (resource.toOne.containsKey(relationship)) {
      final related = resource.toOne[relationship];
      if (related == null) {
        return JsonApiResponse.relatedResource(null);
      }
      return JsonApiResponse.relatedResource(_repo(related.type)[related.id]);
    }
    if (resource.toMany.containsKey(relationship)) {
      return JsonApiResponse.relatedCollection(
          resource.toMany[relationship].map((r) => _repo(r.type)[r.id]));
    }
    return JsonApiResponse.notFound(
        [JsonApiError(detail: 'Relatioship not found')]);
  }

  @override
  FutureOr<JsonApiResponse> fetchRelationship(
      Request request, String type, String id, String relationship) {
    final r = _repo(type)[id];
    if (r.toOne.containsKey(relationship)) {
      return JsonApiResponse.toOne(
          type, id, relationship, r.toOne[relationship]);
    }
    if (r.toMany.containsKey(relationship)) {
      return JsonApiResponse.toMany(
          type, id, relationship, r.toMany[relationship]);
    }
    return JsonApiResponse.notFound(
        [JsonApiError(detail: 'Relationship not found')]);
  }

  @override
  FutureOr<JsonApiResponse> updateResource(
      Request request, String type, String id, Resource resource) {
    final current = _repo(type)[id];
    if (resource.hasAllMembersOf(current)) {
      _repo(type)[id] = resource;
      return JsonApiResponse.noContent();
    }
    _repo(type)[id] = resource.withExtraMembersFrom(current);
    return JsonApiResponse.resourceUpdated(_repo(type)[id]);
  }

  @override
  FutureOr<JsonApiResponse> replaceToMany(Request request, String type,
      String id, String relationship, Iterable<Identifier> identifiers) {
    final resource = _repo(type)[id];
    final toMany = {...resource.toMany, relationship: identifiers.toList()};
    _repo(type)[id] = resource.replace(toMany: toMany);
    return JsonApiResponse.toMany(type, id, relationship, identifiers);
  }

  @override
  FutureOr<JsonApiResponse> replaceToOne(Request request, String type,
      String id, String relationship, Identifier identifier) {
    _repo(type)[id] =
        _repo(type)[id].replace(toOne: {relationship: identifier});
    return JsonApiResponse.noContent();
  }

  Map<String, Resource> _repo(String type) {
    store.putIfAbsent(type, () => {});
    return store[type];
  }
}
