import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/server.dart';
import 'package:shelf/shelf.dart';

class CRUDController implements JsonApiController<Request> {
  final String Function() generateId;

  final store = <String, Map<String, Resource>>{};

  CRUDController(this.generateId);

  @override
  FutureOr<ControllerResponse> createResource(
      Request request, String type, Resource resource) {
    if (resource.type != type) {
      return ErrorResponse.conflict(
          [JsonApiError(detail: 'Incompatible type')]);
    }
    final repo = _repo(type);
    if (resource.id != null) {
      if (repo.containsKey(resource.id)) {
        return ErrorResponse.conflict(
            [JsonApiError(detail: 'Resource already exists')]);
      }
      repo[resource.id] = resource;
      return NoContentResponse();
    }
    final id = generateId();
    repo[id] = resource.replace(id: id);
    return ResourceCreatedResponse(repo[id]);
  }

  @override
  FutureOr<ControllerResponse> fetchResource(
      Request request, String type, String id) {
    final repo = _repo(type);
    if (repo.containsKey(id)) {
      return ResourceResponse(repo[id]);
    }
    return ErrorResponse.notFound(
        [JsonApiError(detail: 'Resource not found', status: '404')]);
  }

  @override
  FutureOr<ControllerResponse> addToRelationship(Request request, String type,
      String id, String relationship, Iterable<Identifier> identifiers) {
    final resource = _repo(type)[id];
    final ids = [...resource.toMany[relationship], ...identifiers];
    _repo(type)[id] =
        resource.replace(toMany: {...resource.toMany, relationship: ids});
    return ToManyResponse(type, id, relationship, ids);
  }

  @override
  FutureOr<ControllerResponse> deleteFromRelationship(
      Request request,
      String type,
      String id,
      String relationship,
      Iterable<Identifier> identifiers) {
    final resource = _repo(type)[id];
    final rel = [...resource.toMany[relationship]];
    rel.removeWhere(identifiers.contains);
    final toMany = {...resource.toMany};
    toMany[relationship] = rel;
    _repo(type)[id] = resource.replace(toMany: toMany);

    return ToManyResponse(type, id, relationship, rel);
  }

  @override
  FutureOr<ControllerResponse> deleteResource(
      Request request, String type, String id) {
    final repo = _repo(type);
    if (!repo.containsKey(id)) {
      return ErrorResponse.notFound(
          [JsonApiError(detail: 'Resource not found')]);
    }
    final resource = repo[id];
    repo.remove(id);
    final relationships = {...resource.toOne, ...resource.toMany};
    if (relationships.isNotEmpty) {
      return MetaResponse({'relationships': relationships.length});
    }
    return NoContentResponse();
  }

  @override
  FutureOr<ControllerResponse> fetchCollection(Request request, String type) {
    final repo = _repo(type);
    return CollectionResponse(repo.values);
  }

  @override
  FutureOr<ControllerResponse> fetchRelated(
      Request request, String type, String id, String relationship) {
    final resource = _repo(type)[id];
    if (resource == null) {
      return ErrorResponse.notFound(
          [JsonApiError(detail: 'Resource not found')]);
    }
    if (resource.toOne.containsKey(relationship)) {
      final related = resource.toOne[relationship];
      if (related == null) {
        return RelatedResourceResponse(null);
      }
      return RelatedResourceResponse(_repo(related.type)[related.id]);
    }
    if (resource.toMany.containsKey(relationship)) {
      return RelatedCollectionResponse(
          resource.toMany[relationship].map((r) => _repo(r.type)[r.id]));
    }
    return ErrorResponse.notFound(
        [JsonApiError(detail: 'Relatioship not found')]);
  }

  @override
  FutureOr<ControllerResponse> fetchRelationship(
      Request request, String type, String id, String relationship) {
    final r = _repo(type)[id];
    if (r.toOne.containsKey(relationship)) {
      return ToOneResponse(type, id, relationship, r.toOne[relationship]);
    }
    if (r.toMany.containsKey(relationship)) {
      return ToManyResponse(type, id, relationship, r.toMany[relationship]);
    }
    return ErrorResponse.notFound(
        [JsonApiError(detail: 'Relationship not found')]);
  }

  @override
  FutureOr<ControllerResponse> updateResource(
      Request request, String type, String id, Resource resource) {
    final current = _repo(type)[id];
    if (resource.hasAllMembersOf(current)) {
      _repo(type)[id] = resource;
      return NoContentResponse();
    }
    _repo(type)[id] = resource.withExtraMembersFrom(current);
    return ResourceUpdatedResponse(_repo(type)[id]);
  }

  @override
  FutureOr<ControllerResponse> replaceToMany(Request request, String type,
      String id, String relationship, Iterable<Identifier> identifiers) {
    final resource = _repo(type)[id];
    final toMany = {...resource.toMany, relationship: identifiers.toList()};
    _repo(type)[id] = resource.replace(toMany: toMany);
    return ToManyResponse(type, id, relationship, identifiers);
  }

  @override
  FutureOr<ControllerResponse> replaceToOne(Request request, String type,
      String id, String relationship, Identifier identifier) {
    _repo(type)[id] =
        _repo(type)[id].replace(toOne: {relationship: identifier});
    return NoContentResponse();
  }

  Map<String, Resource> _repo(String type) {
    store.putIfAbsent(type, () => {});
    return store[type];
  }
}
