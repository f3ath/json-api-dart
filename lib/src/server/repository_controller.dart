import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/query.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/json_api_response.dart';
import 'package:json_api/src/server/repository.dart';

/// An opinionated implementation of [Controller]. It translates JSON:API
/// requests to [Repository] methods calls.
class RepositoryController<R> implements Controller<FutureOr<JsonApiResponse>> {
  RepositoryController(this._repo);

  final Repository _repo;

  @override
  FutureOr<JsonApiResponse> addToRelationship(String type, String id,
          String relationship, Iterable<Identifier> identifiers) =>
      _do(() async {
        final original = await _repo.get(type, id);
        if (!original.toMany.containsKey(relationship)) {
          return ErrorResponse.notFound([
            ErrorObject(
                status: '404',
                title: 'Relationship not found',
                detail:
                    "There is no to-many relationship '${relationship}' in this resource")
          ]);
        }
        final updated = await _repo.update(
            type,
            id,
            Resource(type, id, toMany: {
              relationship:
                  {...original.toMany[relationship], ...identifiers}.toList()
            }));
        return ToManyResponse(
            type, id, relationship, updated.toMany[relationship]);
      });

  @override
  FutureOr<JsonApiResponse> createResource(String type, Resource resource) =>
      _do(() async {
        final modified = await _repo.create(type, resource);
        if (modified == null) return NoContentResponse();
        return ResourceCreatedResponse(modified);
      });

  @override
  FutureOr<JsonApiResponse> deleteFromRelationship(String type, String id,
          String relationship, Iterable<Identifier> identifiers) =>
      _do(() async {
        final original = await _repo.get(type, id);
        final updated = await _repo.update(
            type,
            id,
            Resource(type, id, toMany: {
              relationship: ({...original.toMany[relationship]}
                    ..removeAll(identifiers))
                  .toList()
            }));
        return ToManyResponse(
            type, id, relationship, updated.toMany[relationship]);
      });

  @override
  FutureOr<JsonApiResponse> deleteResource(String type, String id) =>
      _do(() async {
        await _repo.delete(type, id);
        return NoContentResponse();
      });

  @override
  FutureOr<JsonApiResponse> fetchCollection(
          String type, Map<String, List<String>> queryParameters) =>
      _do(() async {
        final c = await _repo.getCollection(type);
        final include = Include.fromQueryParameters(queryParameters);

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
  FutureOr<JsonApiResponse> fetchRelated(String type, String id,
          String relationship, Map<String, List<String>> queryParameters) =>
      _do(() async {
        final resource = await _repo.get(type, id);
        if (resource.toOne.containsKey(relationship)) {
          return ResourceResponse(
              await _getByIdentifier(resource.toOne[relationship]));
        }
        if (resource.toMany.containsKey(relationship)) {
          final related = <Resource>[];
          for (final identifier in resource.toMany[relationship]) {
            related.add(await _getByIdentifier(identifier));
          }
          return CollectionResponse(related);
        }
        return _relationshipNotFound(relationship);
      });

  @override
  FutureOr<JsonApiResponse> fetchRelationship(String type, String id,
          String relationship, Map<String, List<String>> queryParameters) =>
      _do(() async {
        final resource = await _repo.get(type, id);
        if (resource.toOne.containsKey(relationship)) {
          return ToOneResponse(
              type, id, relationship, resource.toOne[relationship]);
        }
        if (resource.toMany.containsKey(relationship)) {
          return ToManyResponse(
              type, id, relationship, resource.toMany[relationship]);
        }
        return _relationshipNotFound(relationship);
      });

  @override
  FutureOr<JsonApiResponse> fetchResource(
          String type, String id, Map<String, List<String>> queryParameters) =>
      _do(() async {
        final include = Include.fromQueryParameters(queryParameters);
        final resource = await _repo.get(type, id);
        final resources = <Resource>[];
        for (final path in include) {
          resources.addAll(await _getRelated(resource, path.split('.')));
        }
        return ResourceResponse(resource,
            included: include.isEmpty ? null : resources);
      });

  @override
  FutureOr<JsonApiResponse> replaceToMany(String type, String id,
          String relationship, Iterable<Identifier> identifiers) =>
      _do(() async {
        await _repo.update(
            type, id, Resource(type, id, toMany: {relationship: identifiers}));
        return NoContentResponse();
      });

  @override
  FutureOr<JsonApiResponse> updateResource(
          String type, String id, Resource resource) =>
      _do(() async {
        final modified = await _repo.update(type, id, resource);
        if (modified == null) return NoContentResponse();
        return ResourceResponse(modified);
      });

  @override
  FutureOr<JsonApiResponse> replaceToOne(
          String type, String id, String relationship, Identifier identifier) =>
      _do(() async {
        await _repo.update(
            type, id, Resource(type, id, toOne: {relationship: identifier}));
        return NoContentResponse();
      });

  @override
  FutureOr<JsonApiResponse> deleteToOne(
          String type, String id, String relationship) =>
      replaceToOne(type, id, relationship, null);

  FutureOr<Resource> _getByIdentifier(Identifier identifier) =>
      _repo.get(identifier.type, identifier.id);

  Future<Iterable<Resource>> _getRelated(
    Resource resource,
    Iterable<String> path,
  ) async {
    if (path.isEmpty) return [];
    final resources = <Resource>[];
    final ids = <Identifier>[];

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
    return _unique(resources);
  }

  Iterable<Resource> _unique(Iterable<Resource> included) =>
      Map<String, Resource>.fromIterable(included,
          key: (_) => '${_.type}:${_.id}').values;

  FutureOr<JsonApiResponse> _do(
      FutureOr<JsonApiResponse> Function() action) async {
    try {
      return await action();
    } on UnsupportedOperation catch (e) {
      return ErrorResponse.forbidden([
        ErrorObject(
            status: '403', title: 'Unsupported operation', detail: e.message)
      ]);
    } on CollectionNotFound catch (e) {
      return ErrorResponse.notFound([
        ErrorObject(
            status: '404', title: 'Collection not found', detail: e.message)
      ]);
    } on ResourceNotFound catch (e) {
      return ErrorResponse.notFound([
        ErrorObject(
            status: '404', title: 'Resource not found', detail: e.message)
      ]);
    } on InvalidType catch (e) {
      return ErrorResponse.conflict([
        ErrorObject(
            status: '409', title: 'Invalid resource type', detail: e.message)
      ]);
    } on ResourceExists catch (e) {
      return ErrorResponse.conflict([
        ErrorObject(status: '409', title: 'Resource exists', detail: e.message)
      ]);
    }
  }

  JsonApiResponse _relationshipNotFound(String relationship) {
    return ErrorResponse.notFound([
      ErrorObject(
          status: '404',
          title: 'Relationship not found',
          detail:
              "Relationship '$relationship' does not exist in this resource")
    ]);
  }
}
