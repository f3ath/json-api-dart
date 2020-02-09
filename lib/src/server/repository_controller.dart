import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/query.dart';
import 'package:json_api/src/server/json_api_controller.dart';
import 'package:json_api/src/server/json_api_response.dart';
import 'package:json_api/src/server/repository.dart';
import 'package:json_api/uri_design.dart';

typedef UriReader<R> = FutureOr<Uri> Function(R request);

/// An opinionated implementation of [JsonApiController]
class RepositoryController<R> implements JsonApiController {
  @override
  FutureOr<JsonApiResponse> addToRelationship(HttpRequest request,
          RelationshipTarget target, Iterable<Identifier> identifiers) =>
      _do(() async {
        final original = await _repo.get(target.type, target.id);
        if (!original.toMany.containsKey(target.relationship)) {
          return JsonApiResponse.notFound([
            JsonApiError(
                status: '404',
                title: 'Relationship not found',
                detail:
                    "There is no to-many relationship '${target.relationship}' in this resource")
          ]);
        }
        final updated = await _repo.update(
            target.type,
            target.id,
            Resource(target.type, target.id, toMany: {
              target.relationship: {
                ...original.toMany[target.relationship],
                ...identifiers
              }
            }));
        return JsonApiResponse.toMany(target.type, target.id,
            target.relationship, updated.toMany[target.relationship]);
      });

  @override
  FutureOr<JsonApiResponse> createResource(
          HttpRequest request, CollectionTarget target, Resource resource) =>
      _do(() async {
        final modified = await _repo.create(target.type, resource);
        if (modified == null) return JsonApiResponse.noContent();
        return JsonApiResponse.resourceCreated(modified);
      });

  @override
  FutureOr<JsonApiResponse> deleteFromRelationship(HttpRequest request,
          RelationshipTarget target, Iterable<Identifier> identifiers) =>
      _do(() async {
        final original = await _repo.get(target.type, target.id);
        final updated = await _repo.update(
            target.type,
            target.id,
            Resource(target.type, target.id, toMany: {
              target.relationship: {...original.toMany[target.relationship]}
                ..removeAll(identifiers)
            }));
        return JsonApiResponse.toMany(target.type, target.id,
            target.relationship, updated.toMany[target.relationship]);
      });

  @override
  FutureOr<JsonApiResponse> deleteResource(
          HttpRequest request, ResourceTarget target) =>
      _do(() async {
        await _repo.delete(target.type, target.id);
        return JsonApiResponse.noContent();
      });

  @override
  FutureOr<JsonApiResponse> fetchCollection(
          HttpRequest request, CollectionTarget target) =>
      _do(() async {
        final c = await _repo.getCollection(target.type);
        final include = Include.fromUri(request.uri);

        final resources = <Resource>[];
        for (final resource in c.elements) {
          for (final path in include) {
            resources.addAll(await _getRelated(resource, path.split('.')));
          }
        }

        return JsonApiResponse.collection(c.elements,
            total: c.total, included: include.isEmpty ? null : resources);
      });

  @override
  FutureOr<JsonApiResponse> fetchRelated(
          HttpRequest request, RelatedTarget target) =>
      _do(() async {
        final resource = await _repo.get(target.type, target.id);
        if (resource.toOne.containsKey(target.relationship)) {
          final identifier = resource.toOne[target.relationship];
          return JsonApiResponse.resource(await _getByIdentifier(identifier));
        }
        if (resource.toMany.containsKey(target.relationship)) {
          final related = <Resource>[];
          for (final identifier in resource.toMany[target.relationship]) {
            related.add(await _getByIdentifier(identifier));
          }
          return JsonApiResponse.collection(related);
        }
        return _relationshipNotFound(target.relationship);
      });

  @override
  FutureOr<JsonApiResponse> fetchRelationship(
          HttpRequest request, RelationshipTarget target) =>
      _do(() async {
        final resource = await _repo.get(target.type, target.id);
        if (resource.toOne.containsKey(target.relationship)) {
          return JsonApiResponse.toOne(target.type, target.id,
              target.relationship, resource.toOne[target.relationship]);
        }
        if (resource.toMany.containsKey(target.relationship)) {
          return JsonApiResponse.toMany(target.type, target.id,
              target.relationship, resource.toMany[target.relationship]);
        }
        return _relationshipNotFound(target.relationship);
      });

  @override
  FutureOr<JsonApiResponse> fetchResource(
          HttpRequest request, ResourceTarget target) =>
      _do(() async {
        final include = Include.fromUri(request.uri);
        final resource = await _repo.get(target.type, target.id);
        final resources = <Resource>[];
        for (final path in include) {
          resources.addAll(await _getRelated(resource, path.split('.')));
        }
        return JsonApiResponse.resource(resource,
            included: include.isEmpty ? null : resources);
      });

  @override
  FutureOr<JsonApiResponse> replaceToMany(HttpRequest request,
          RelationshipTarget target, Iterable<Identifier> identifiers) =>
      _do(() async {
        await _repo.update(
            target.type,
            target.id,
            Resource(target.type, target.id,
                toMany: {target.relationship: identifiers}));
        return JsonApiResponse.noContent();
      });

  @override
  FutureOr<JsonApiResponse> updateResource(
          HttpRequest request, ResourceTarget target, Resource resource) =>
      _do(() async {
        final modified = await _repo.update(target.type, target.id, resource);
        if (modified == null) return JsonApiResponse.noContent();
        return JsonApiResponse.resource(modified);
      });

  @override
  FutureOr<JsonApiResponse> replaceToOne(HttpRequest request,
          RelationshipTarget target, Identifier identifier) =>
      _do(() async {
        await _repo.update(
            target.type,
            target.id,
            Resource(target.type, target.id,
                toOne: {target.relationship: identifier}));
        return JsonApiResponse.noContent();
      });

  RepositoryController(this._repo);

  final Repository _repo;

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
    return resources;
  }

  FutureOr<JsonApiResponse> _do(
      FutureOr<JsonApiResponse> Function() action) async {
    try {
      return await action();
    } on UnsupportedOperation catch (e) {
      return JsonApiResponse.forbidden([
        JsonApiError(
            status: '403', title: 'Unsupported operation', detail: e.message)
      ]);
    } on CollectionNotFound catch (e) {
      return JsonApiResponse.notFound([
        JsonApiError(
            status: '404', title: 'Collection not found', detail: e.message)
      ]);
    } on ResourceNotFound catch (e) {
      return JsonApiResponse.notFound([
        JsonApiError(
            status: '404', title: 'Resource not found', detail: e.message)
      ]);
    } on InvalidType catch (e) {
      return JsonApiResponse.conflict([
        JsonApiError(
            status: '409', title: 'Invalid resource type', detail: e.message)
      ]);
    } on ResourceExists catch (e) {
      return JsonApiResponse.conflict([
        JsonApiError(status: '409', title: 'Resource exists', detail: e.message)
      ]);
    }
  }

  JsonApiResponse _relationshipNotFound(
    String relationship,
  ) {
    return JsonApiResponse.notFound([
      JsonApiError(
          status: '404',
          title: 'Relationship not found',
          detail:
              "Relationship '$relationship' does not exist in this resource")
    ]);
  }
}
