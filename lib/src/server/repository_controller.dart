import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/src/server/json_api_controller.dart';
import 'package:json_api/src/server/json_api_response.dart';
import 'package:json_api/src/server/repository/repository.dart';

/// An opinionated implementation of [JsonApiController]
class RepositoryController<R> implements JsonApiController<R> {
  final Repository _repo;

  RepositoryController(this._repo);

  @override
  FutureOr<JsonApiResponse> addToRelationship(R request, String type, String id,
          String relationship, Iterable<Identifier> identifiers) =>
      _do(() async {
        final original = await _repo.get(type, id);
        final updated = await _repo.update(
            type,
            id,
            Resource(type, id, toMany: {
              relationship: [...original.toMany[relationship], ...identifiers]
            }));
        return JsonApiResponse.toMany(
            type, id, relationship, updated.toMany[relationship]);
      });

  @override
  FutureOr<JsonApiResponse> createResource(
          R request, String type, Resource resource) =>
      _do(() async {
        final modified = await _repo.create(type, resource);
        if (modified == null) return JsonApiResponse.noContent();
        return JsonApiResponse.resourceCreated(modified);
      });

  @override
  FutureOr<JsonApiResponse> deleteFromRelationship(R request, String type,
      String id, String relationship, Iterable<Identifier> identifiers) {
    // TODO: implement deleteFromRelationship
    return null;
  }

  @override
  FutureOr<JsonApiResponse> deleteResource(R request, String type, String id) {
    // TODO: implement deleteResource
    return null;
  }

  @override
  FutureOr<JsonApiResponse> fetchCollection(R request, String type) {
    // TODO: implement fetchCollection
    return null;
  }

  @override
  FutureOr<JsonApiResponse> fetchRelated(
      R request, String type, String id, String relationship) {
    // TODO: implement fetchRelated
    return null;
  }

  @override
  FutureOr<JsonApiResponse> fetchRelationship(
      R request, String type, String id, String relationship) {
    // TODO: implement fetchRelationship
    return null;
  }

  @override
  FutureOr<JsonApiResponse> fetchResource(
      R request, String type, String id) async {
    return JsonApiResponse.resource(await _repo.get(type, id));
  }

  @override
  FutureOr<JsonApiResponse> replaceToMany(R request, String type, String id,
          String relationship, Iterable<Identifier> identifiers) =>
      _do(() async {
        await _repo.update(
            type, id, Resource(type, id, toMany: {relationship: identifiers}));
        return JsonApiResponse.noContent();
      });

  @override
  FutureOr<JsonApiResponse> replaceToOne(R request, String type, String id,
          String relationship, Identifier identifier) =>
      _do(() async {
        await _repo.update(
            type, id, Resource(type, id, toOne: {relationship: identifier}));
        return JsonApiResponse.noContent();
      });

  @override
  FutureOr<JsonApiResponse> updateResource(
          R request, String type, String id, Resource resource) =>
      _do(() async {
        final modified = await _repo.update(type, id, resource);
        if (modified == null) return JsonApiResponse.noContent();
        return JsonApiResponse.resource(modified);
      });

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
}
