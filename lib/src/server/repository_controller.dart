import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/query.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/json_api_response.dart';
import 'package:json_api/src/server/repository.dart';
import 'package:json_api/src/server/resource_target.dart';

/// An opinionated implementation of [Controller]. Translates JSON:API
/// requests to [Repository] methods calls.
class RepositoryController<R> implements Controller<FutureOr<JsonApiResponse>> {
  RepositoryController(this._repo, {Pagination pagination})
      : _pagination = pagination ?? NoPagination();

  final Repository _repo;
  final Pagination _pagination;

  @override
  FutureOr<JsonApiResponse> addToRelationship(AddToRelationship request) =>
      _do(() async {
        final original = await _repo.get(request.target.resource);
        if (!original.toMany.containsKey(request.target.relationship)) {
          return ErrorResponse.notFound([
            ErrorObject(
                status: '404',
                title: 'Relationship not found',
                detail:
                    "There is no to-many relationship '${request.target.relationship}' in this resource")
          ]);
        }
        final updated = await _repo.update(
            request.target.resource,
            Resource(request.target.type, request.target.id, toMany: {
              request.target.relationship: {
                ...original.toMany[request.target.relationship],
                ...request.identifiers
              }.toList()
            }));
        return ToManyResponse(
            request.target, updated.toMany[request.target.relationship]);
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
        final original = await _repo.get(request.target.resource);
        final updated = await _repo.update(
            request.target.resource,
            Resource(request.target.type, request.target.id, toMany: {
              request.target.relationship: ({
                ...original.toMany[request.target.relationship]
              }..removeAll(request.identifiers))
                  .toList()
            }));
        return ToManyResponse(
            request.target, updated.toMany[request.target.relationship]);
      });

  @override
  FutureOr<JsonApiResponse> deleteResource(DeleteResource request) =>
      _do(() async {
        await _repo.delete(request.target);
        return NoContentResponse();
      });

  @override
  FutureOr<JsonApiResponse> fetchCollection(FetchCollection request) =>
      _do(() async {
        final sort = Sort.fromQueryParameters(request.queryParameters);
        final include = Include.fromQueryParameters(request.queryParameters);
        final page = Page.fromQueryParameters(request.queryParameters);
        final limit = _pagination.limit(page);
        final offset = _pagination.offset(page);

        final c = await _repo.getCollection(request.type,
            sort: sort.toList(), limit: limit, offset: offset);

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
        final resource = await _repo.get(request.target.resource);
        if (resource.toOne.containsKey(request.target.relationship)) {
          return ResourceResponse(await _repo.get(ResourceTarget.fromIdentifier(
              resource.toOne[request.target.relationship])));
        }
        if (resource.toMany.containsKey(request.target.relationship)) {
          final related = <Resource>[];
          for (final identifier
              in resource.toMany[request.target.relationship]) {
            related.add(
                await _repo.get(ResourceTarget.fromIdentifier(identifier)));
          }
          return CollectionResponse(related);
        }
        return _relationshipNotFound(request.target.relationship);
      });

  @override
  FutureOr<JsonApiResponse> fetchRelationship(FetchRelationship request) =>
      _do(() async {
        final resource = await _repo.get(request.target.resource);
        if (resource.toOne.containsKey(request.target.relationship)) {
          return ToOneResponse(
              request.target, resource.toOne[request.target.relationship]);
        }
        if (resource.toMany.containsKey(request.target.relationship)) {
          return ToManyResponse(
              request.target, resource.toMany[request.target.relationship]);
        }
        return _relationshipNotFound(request.target.relationship);
      });

  @override
  FutureOr<JsonApiResponse> fetchResource(FetchResource request) =>
      _do(() async {
        final include = Include.fromQueryParameters(request.queryParameters);
        final resource = await _repo.get(request.target);
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
            request.target.resource,
            Resource(request.target.type, request.target.id,
                toMany: {request.target.relationship: request.identifiers}));
        return NoContentResponse();
      });

  @override
  FutureOr<JsonApiResponse> updateResource(UpdateResource request) =>
      _do(() async {
        final modified = await _repo.update(request.target, request.resource);
        if (modified == null) return NoContentResponse();
        return ResourceResponse(modified);
      });

  @override
  FutureOr<JsonApiResponse> replaceToOne(ReplaceToOne request) => _do(() async {
        await _repo.update(
            request.target.resource,
            Resource(request.target.type, request.target.id,
                toOne: {request.target.relationship: request.identifier}));
        return NoContentResponse();
      });

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
      final r = await _repo.get(ResourceTarget.fromIdentifier(id));
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
