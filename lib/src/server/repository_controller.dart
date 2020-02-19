import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/server/json_api_request.dart';
import 'package:json_api/src/server/json_api_response.dart';
import 'package:json_api/src/server/repository.dart';

/// An opinionated implementation of [JsonApiController]
class RepositoryController<R> implements JsonApiController {
  @override
  FutureOr<JsonApiResponse> addToRelationship(AddToRelationship request) =>
      _do(() async {
        final original = await _repo.get(request.type, request.id);
        if (!original.toMany.containsKey(request.relationship)) {
          return ErrorResponse.notFound([
            JsonApiError(
                status: '404',
                title: 'Relationship not found',
                detail:
                    "There is no to-many relationship '${request.relationship}' in this resource")
          ]);
        }
        final updated = await _repo.update(
            request.type,
            request.id,
            Resource(request.type, request.id, toMany: {
              request.relationship: {
                ...original.toMany[request.relationship],
                ...request.identifiers
              }
            }));
        return ToManyResponse(request.type, request.id, request.relationship,
            updated.toMany[request.relationship]);
      });

  @override
  FutureOr<JsonApiResponse> createResource(CreateResource request) =>
      _do(() async {
        final modified = await _repo.create(request.type, request.resource);
        if (modified == null) return NoContentResponse();
        return ResourceCreatedResponse(modified);
      });

  @override
  FutureOr<JsonApiResponse> deleteFromRelationship(
          DeleteFromRelationship request) =>
      _do(() async {
        final original = await _repo.get(request.type, request.id);
        final updated = await _repo.update(
            request.type,
            request.id,
            Resource(request.type, request.id, toMany: {
              request.relationship: {...original.toMany[request.relationship]}
                ..removeAll(request.identifiers)
            }));
        return ToManyResponse(request.type, request.id, request.relationship,
            updated.toMany[request.relationship]);
      });

  @override
  FutureOr<JsonApiResponse> deleteResource(DeleteResource request) =>
      _do(() async {
        await _repo.delete(request.type, request.id);
        return NoContentResponse();
      });

  @override
  FutureOr<JsonApiResponse> fetchCollection(FetchCollection request) =>
      _do(() async {
        final c = await _repo.getCollection(request.type);
        final include = request.include;

        final resources = <Resource>[];
        for (final resource in c.elements) {
          for (final path in include) {
            resources.addAll(await _getRelated(resource, path.split('.')));
          }
        }

        return CollectionResponse(c.elements,
            total: c.total, included: include.isEmpty ? null : resources);
      });

  @override
  FutureOr<JsonApiResponse> fetchRelated(FetchRelated request) => _do(() async {
        final resource = await _repo.get(request.type, request.id);
        if (resource.toOne.containsKey(request.relationship)) {
          return ResourceResponse(
              await _getByIdentifier(resource.toOne[request.relationship]));
        }
        if (resource.toMany.containsKey(request.relationship)) {
          final related = <Resource>[];
          for (final identifier in resource.toMany[request.relationship]) {
            related.add(await _getByIdentifier(identifier));
          }
          return CollectionResponse(related);
        }
        return _relationshipNotFound(request.relationship);
      });

  @override
  FutureOr<JsonApiResponse> fetchRelationship(FetchRelationship request) =>
      _do(() async {
        final resource = await _repo.get(request.type, request.id);
        if (resource.toOne.containsKey(request.relationship)) {
          return ToOneResponse(request.type, request.id, request.relationship,
              resource.toOne[request.relationship]);
        }
        if (resource.toMany.containsKey(request.relationship)) {
          return ToManyResponse(request.type, request.id, request.relationship,
              resource.toMany[request.relationship]);
        }
        return _relationshipNotFound(request.relationship);
      });

  @override
  FutureOr<JsonApiResponse> fetchResource(FetchResource request) =>
      _do(() async {
        final include = request.include;
        final resource = await _repo.get(request.type, request.id);
        final resources = <Resource>[];
        for (final path in include) {
          resources.addAll(await _getRelated(resource, path.split('.')));
        }
        return ResourceResponse(resource,
            included: include.isEmpty ? null : resources);
      });

  @override
  FutureOr<JsonApiResponse> replaceToMany(ReplaceToMany request) =>
      _do(() async {
        await _repo.update(
            request.type,
            request.id,
            Resource(request.type, request.id,
                toMany: {request.relationship: request.identifiers}));
        return NoContentResponse();
      });

  @override
  FutureOr<JsonApiResponse> updateResource(UpdateResource request) =>
      _do(() async {
        final modified =
            await _repo.update(request.type, request.id, request.resource);
        if (modified == null) return NoContentResponse();
        return ResourceResponse(modified);
      });

  @override
  FutureOr<JsonApiResponse> replaceToOne(ReplaceToOne request) => _do(() async {
        await _repo.update(
            request.type,
            request.id,
            Resource(request.type, request.id,
                toOne: {request.relationship: request.identifier}));
        return NoContentResponse();
      });

  RepositoryController(this._repo);

  final Repository _repo;

  FutureOr<Resource> _getByIdentifier(Identifiers identifier) =>
      _repo.get(identifier.type, identifier.id);

  Future<Iterable<Resource>> _getRelated(
    Resource resource,
    Iterable<String> path,
  ) async {
    if (path.isEmpty) return [];
    final resources = <Resource>[];
    final ids = <Identifiers>[];

    if (resource.toOne.containsKey(path.first)) {
      ids.add(resource.toOne[path.first]);
    } else if (resource.toMany.containsKey(path.first)) {
      ids.addAll(resource.toMany[path.first]);
    }
    for (final id in ids) {
      final r = await _getByIdentifier(id);
      if (path.length > 1) {
        resources.addAll(await _getRelated(r, path.skip(1)));
      } else {
        resources.add(r);
      }
    }
    return resources;
  }

  FutureOr<JsonApiResponse> _do(
      FutureOr<JsonApiResponse> Function() action) async {
    try {
      return await action();
    } on UnsupportedOperation catch (e) {
      return ErrorResponse.forbidden([
        JsonApiError(
            status: '403', title: 'Unsupported operation', detail: e.message)
      ]);
    } on CollectionNotFound catch (e) {
      return ErrorResponse.notFound([
        JsonApiError(
            status: '404', title: 'Collection not found', detail: e.message)
      ]);
    } on ResourceNotFound catch (e) {
      return ErrorResponse.notFound([
        JsonApiError(
            status: '404', title: 'Resource not found', detail: e.message)
      ]);
    } on InvalidType catch (e) {
      return ErrorResponse.conflict([
        JsonApiError(
            status: '409', title: 'Invalid resource type', detail: e.message)
      ]);
    } on ResourceExists catch (e) {
      return ErrorResponse.conflict([
        JsonApiError(status: '409', title: 'Resource exists', detail: e.message)
      ]);
    }
  }

  JsonApiResponse _relationshipNotFound(
    String relationship,
  ) {
    return ErrorResponse.notFound([
      JsonApiError(
          status: '404',
          title: 'Relationship not found',
          detail:
              "Relationship '$relationship' does not exist in this resource")
    ]);
  }
}
