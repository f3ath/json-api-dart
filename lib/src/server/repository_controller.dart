import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/src/server/collection.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/controller_request.dart';
import 'package:json_api/src/server/controller_response.dart';
import 'package:json_api/src/server/pagination.dart';
import 'package:json_api/src/server/repository.dart';

/// An opinionated implementation of [Controller]. Translates JSON:API
/// requests to [Repository] methods calls.
class RepositoryController implements Controller {
  RepositoryController(this._repo, {Pagination pagination})
      : _pagination = pagination ?? NoPagination();

  final Repository _repo;
  final Pagination _pagination;

  @override
  Future<ControllerResponse> addToRelationship(
          RelationshipRequest request, List<Identifier> identifiers) =>
      _do(() async {
        final original = await _repo.get(request.type, request.id);
        if (!original.toMany.containsKey(request.relationship)) {
          return ErrorResponse(404, [
            ErrorObject(
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
                ...identifiers
              }.toList()
            }));
        return request.toManyResponse(updated.toMany[request.relationship]);
      });

  @override
  Future<ControllerResponse> createResource(
          CollectionRequest request, Resource resource) =>
      _do(() async {
        final modified = await _repo.create(request.type, resource);
        if (modified == null) {
          return NoContentResponse();
        }
        return request.resourceResponse(modified);
      });

  @override
  Future<ControllerResponse> deleteFromRelationship(
          RelationshipRequest request, List<Identifier> identifiers) =>
      _do(() async {
        final original = await _repo.get(request.type, request.id);
        final updated = await _repo.update(
            request.type,
            request.id,
            Resource(request.type, request.id, toMany: {
              request.relationship: ({...original.toMany[request.relationship]}
                    ..removeAll(identifiers))
                  .toList()
            }));
        return request.toManyResponse(updated.toMany[request.relationship]);
      });

  @override
  Future<ControllerResponse> deleteResource(ResourceRequest request) =>
      _do(() async {
        await _repo.delete(request.type, request.id);
        return NoContentResponse();
      });

  @override
  Future<ControllerResponse> fetchCollection(CollectionRequest request) =>
      _do(() async {
        final limit = _pagination.limit(request.page);
        final offset = _pagination.offset(request.page);

        final collection = await _repo.getCollection(request.type,
            sort: request.sort.toList(), limit: limit, offset: offset);

        final resources = <Resource>[];
        for (final resource in collection.elements) {
          for (final path in request.include) {
            resources.addAll(await _getRelated(resource, path.split('.')));
          }
        }
        return request.collectionResponse(collection,
            include: request.isCompound ? resources : null);
      });

  @override
  Future<ControllerResponse> fetchRelated(RelatedRequest request) =>
      _do(() async {
        final resource = await _repo.get(request.type, request.id);
        if (resource.toOne.containsKey(request.relationship)) {
          final i = resource.toOne[request.relationship];
          return request.resourceResponse(await _repo.get(i.type, i.id));
        }
        if (resource.toMany.containsKey(request.relationship)) {
          final related = <Resource>[];
          for (final identifier in resource.toMany[request.relationship]) {
            related.add(await _repo.get(identifier.type, identifier.id));
          }
          return request.collectionResponse(Collection(related));
        }
        return ErrorResponse(404, _relationshipNotFound(request.relationship));
      });

  @override
  Future<ControllerResponse> fetchRelationship(RelationshipRequest request) =>
      _do(() async {
        final resource = await _repo.get(request.type, request.id);
        if (resource.toOne.containsKey(request.relationship)) {
          return request.toOneResponse(resource.toOne[request.relationship]);
        }
        if (resource.toMany.containsKey(request.relationship)) {
          return request.toManyResponse(resource.toMany[request.relationship]);
        }
        return ErrorResponse(404, _relationshipNotFound(request.relationship));
      });

  @override
  Future<ControllerResponse> fetchResource(ResourceRequest request) =>
      _do(() async {
        final resource = await _repo.get(request.type, request.id);
        final resources = <Resource>[];
        for (final path in request.include) {
          resources.addAll(await _getRelated(resource, path.split('.')));
        }
        return request.resourceResponse(resource,
            include: request.isCompound ? resources : null);
      });

  @override
  Future<ControllerResponse> replaceToMany(
          RelationshipRequest request, List<Identifier> identifiers) =>
      _do(() async {
        await _repo.update(
            request.type,
            request.id,
            Resource(request.type, request.id,
                toMany: {request.relationship: identifiers}));
        return NoContentResponse();
      });

  @override
  Future<ControllerResponse> updateResource(
          ResourceRequest request, Resource resource) =>
      _do(() async {
        final modified = await _repo.update(request.type, request.id, resource);
        if (modified == null) {
          return NoContentResponse();
        }
        return request.resourceResponse(modified);
      });

  @override
  Future<ControllerResponse> replaceToOne(
          RelationshipRequest request, Identifier identifier) =>
      _do(() async {
        await _repo.update(
            request.type,
            request.id,
            Resource(request.type, request.id,
                toOne: {request.relationship: identifier}));
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
      final r = await _repo.get(id.type, id.id);
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

  Future<ControllerResponse> _do(
      Future<ControllerResponse> Function() action) async {
    try {
      return await action();
    } on UnsupportedOperation catch (e) {
      return ErrorResponse(403, [
        ErrorObject(
            status: '403', title: 'Unsupported operation', detail: e.message)
      ]);
    } on CollectionNotFound catch (e) {
      return ErrorResponse(404, [
        ErrorObject(
            status: '404', title: 'Collection not found', detail: e.message)
      ]);
    } on ResourceNotFound catch (e) {
      return ErrorResponse(404, [
        ErrorObject(
            status: '404', title: 'Resource not found', detail: e.message)
      ]);
    } on InvalidType catch (e) {
      return ErrorResponse(409, [
        ErrorObject(
            status: '409', title: 'Invalid resource type', detail: e.message)
      ]);
    } on ResourceExists catch (e) {
      return ErrorResponse(409, [
        ErrorObject(status: '409', title: 'Resource exists', detail: e.message)
      ]);
    }
  }

  List<ErrorObject> _relationshipNotFound(String relationship) => [
        ErrorObject(
            status: '404',
            title: 'Relationship not found',
            detail:
                "Relationship '$relationship' does not exist in this resource")
      ];
}
