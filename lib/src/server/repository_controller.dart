import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/query.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/pagination.dart';
import 'package:json_api/src/server/repository.dart';

/// An opinionated implementation of [Controller]. Translates JSON:API
/// requests to [Repository] methods calls.
class RepositoryController<R> implements Controller {
  RepositoryController(this._repo, {Pagination pagination})
      : _pagination = pagination ?? NoPagination();

  final Repository _repo;
  final Pagination _pagination;

  @override
  Future<void> addToRelationship(
      RelationshipRequest request, Iterable<Identifier> identifiers) {
    return _do(request, () async {
      final original = await _repo.get(request.type, request.id);
      if (!original.toMany.containsKey(request.relationship)) {
        request.sendErrorNotFound([
          ErrorObject(
              status: '404',
              title: 'Relationship not found',
              detail:
                  "There is no to-many relationship '${request.relationship}' in this resource")
        ]);
        return;
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
      request.sendToManyRelationship(updated.toMany[request.relationship]);
    });
  }

  @override
  Future<void> createResource(CollectionRequest request, Resource resource) =>
      _do(request, () async {
        final modified = await _repo.create(request.type, resource);
        if (modified == null) {
          request.sendNoContent();
        } else {
          request.sendCreatedResource(modified);
        }
      });

  @override
  Future<void> deleteFromRelationship(
          RelationshipRequest request, Iterable<Identifier> identifiers) =>
      _do(request, () async {
        final original = await _repo.get(request.type, request.id);
        final updated = await _repo.update(
            request.type,
            request.id,
            Resource(request.type, request.id, toMany: {
              request.relationship: ({...original.toMany[request.relationship]}
                    ..removeAll(identifiers))
                  .toList()
            }));
        request.sendToManyRelationship(updated.toMany[request.relationship]);
      });

  @override
  Future<void> deleteResource(ResourceRequest request) =>
      _do(request, () async {
        await _repo.delete(request.type, request.id);
        request.sendNoContent();
      });

  @override
  Future<void> fetchCollection(CollectionRequest request) =>
      _do(request, () async {
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
        request.sendCollection(c, include: resources);
      });

  @override
  Future<void> fetchRelated(RelatedRequest request) =>
      _do(request, () async {
        final resource = await _repo.get(request.type, request.id);
        if (resource.toOne.containsKey(request.relationship)) {
          final i = resource.toOne[request.relationship];
          request.sendResource(await _repo.get(i.type, i.id));
        } else if (resource.toMany.containsKey(request.relationship)) {
          final related = <Resource>[];
          for (final identifier in resource.toMany[request.relationship]) {
            related.add(await _repo.get(identifier.type, identifier.id));
          }
          request.sendCollection(Collection(related));
        } else {
          request
              .sendErrorNotFound(_relationshipNotFound(request.relationship));
        }
      });

  @override
  Future<void> fetchRelationship(RelationshipRequest request) =>
      _do(request, () async {
        final resource = await _repo.get(request.type, request.id);
        if (resource.toOne.containsKey(request.relationship)) {
          request.sendToOneRelationship(resource.toOne[request.relationship]);
        } else if (resource.toMany.containsKey(request.relationship)) {
          request.sendToManyRelationship(resource.toMany[request.relationship]);
        } else {
          request
              .sendErrorNotFound(_relationshipNotFound(request.relationship));
        }
      });

  @override
  Future<void> fetchResource(ResourceRequest request) => _do(request, () async {
        final include = Include.fromQueryParameters(request.queryParameters);
        final resource = await _repo.get(request.type, request.id);
        final resources = <Resource>[];
        for (final path in include) {
          resources.addAll(await _getRelated(resource, path.split('.')));
        }
        request.sendResource(resource, include: resources);
      });

  @override
  Future<void> replaceToMany(
          RelationshipRequest request, Iterable<Identifier> identifiers) =>
      _do(request, () async {
        await _repo.update(
            request.type,
            request.id,
            Resource(request.type, request.id,
                toMany: {request.relationship: identifiers}));
        request.sendNoContent();
      });

  @override
  Future<void> updateResource(ResourceRequest request, Resource resource) =>
      _do(request, () async {
        final modified = await _repo.update(request.type, request.id, resource);
        if (modified == null) {
          request.sendNoContent();
        } else {
          request.sendResource(modified);
        }
      });

  @override
  Future<void> replaceToOne(
          RelationshipRequest request, Identifier identifier) =>
      _do(request, () async {
        await _repo.update(
            request.type,
            request.id,
            Resource(request.type, request.id,
                toOne: {request.relationship: identifier}));
        request.sendNoContent();
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

  Future<void> _do(
      ControllerRequest request, Future<void> Function() action) async {
    try {
      await action();
    } on UnsupportedOperation catch (e) {
      request.sendErrorForbidden([
        ErrorObject(
            status: '403', title: 'Unsupported operation', detail: e.message)
      ]);
    } on CollectionNotFound catch (e) {
      request.sendErrorNotFound([
        ErrorObject(
            status: '404', title: 'Collection not found', detail: e.message)
      ]);
    } on ResourceNotFound catch (e) {
      request.sendErrorNotFound([
        ErrorObject(
            status: '404', title: 'Resource not found', detail: e.message)
      ]);
    } on InvalidType catch (e) {
      request.sendErrorConflict([
        ErrorObject(
            status: '409', title: 'Invalid resource type', detail: e.message)
      ]);
    } on ResourceExists catch (e) {
      request.sendErrorConflict([
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
