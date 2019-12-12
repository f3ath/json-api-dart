import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/server.dart';
import 'package:uuid/uuid.dart';

import 'dao.dart';
import 'job_queue.dart';

class CarsController implements Controller {
  final Map<String, DAO> _dao;

  final PaginationStrategy _pagination;

  CarsController(this._dao, this._pagination);

  @override
  Response fetchCollection(String type, Uri uri) {
    final page = Page.fromUri(uri);
    final dao = _getDaoOrThrow(type);
    final collection =
        dao.fetchCollection(_pagination.limit(page), _pagination.offset(page));
    return CollectionResponse(collection.elements.map(dao.toResource),
        total: collection.totalCount);
  }

  @override
  Response fetchRelated(String type, String id, String relationship, Uri uri) {
    final res = _fetchResourceOrThrow(type, id);
    final page = Page.fromUri(uri);
    if (res.toOne.containsKey(relationship)) {
      final id = res.toOne[relationship];
      final resource = _dao[id.type].fetchByIdAsResource(id.id);
      return RelatedResourceResponse(resource);
    }
    if (res.toMany.containsKey(relationship)) {
      final relationships = res.toMany[relationship];
      final resources = relationships
          .skip(_pagination.offset(page))
          .take(_pagination.limit(page))
          .map((id) => _dao[id.type].fetchByIdAsResource(id.id));
      return RelatedCollectionResponse(resources, total: relationships.length);
    }
    return ErrorResponse.notFound(
        [JsonApiError(detail: 'Relationship not found')]);
  }

  @override
  Response fetchResource(String type, String id, Uri uri) {
    final dao = _getDaoOrThrow(type);
    final obj = dao.fetchById(id);
    final include = Include.fromUri(uri);

    if (obj == null) {
      return ErrorResponse.notFound(
          [JsonApiError(detail: 'Resource not found')]);
    }
    if (obj is Job && obj.resource != null) {
      return SeeOtherResponse(obj.resource);
    }

    final fetchById = (Identifier _) => _dao[_.type].fetchByIdAsResource(_.id);

    final res = dao.toResource(obj);

    var filter = _filter(res.toMany, include.contains);
    var followedBy = _filter(res.toOne, include.contains)
        .values
        .map(fetchById)
        .followedBy(filter.values.expand((_) => _.map(fetchById)));
    return ResourceResponse(res, included: followedBy);
  }

  @override
  Response fetchRelationship(
      String type, String id, String relationship, Uri uri) {
    final res = _fetchResourceOrThrow(type, id);

    if (res.toOne.containsKey(relationship)) {
      return ToOneResponse(type, id, relationship, res.toOne[relationship]);
    }

    if (res.toMany.containsKey(relationship)) {
      return ToManyResponse(type, id, relationship, res.toMany[relationship]);
    }
    return ErrorResponse.notFound(
        [JsonApiError(detail: 'Relationship not found')]);
  }

  @override
  Response deleteResource(String type, String id) {
    final dao = _getDaoOrThrow(type);

    final res = dao.fetchByIdAsResource(id);
    if (res == null) {
      throw ErrorResponse.notFound(
          [JsonApiError(detail: 'Resource not found')]);
    }
    final dependenciesCount = dao.deleteById(id);
    if (dependenciesCount == 0) {
      return NoContentResponse();
    }
    return MetaResponse({'dependenciesCount': dependenciesCount});
  }

  @override
  Response createResource(String type, Resource resource) {
    final dao = _getDaoOrThrow(type);

    _throwIfIncompatibleTypes(type, resource);

    if (resource.id != null) {
      if (dao.fetchById(resource.id) != null) {
        return ErrorResponse.conflict(
            [JsonApiError(detail: 'Resource already exists')]);
      }
      dao.insert(dao.create(resource));
      return NoContentResponse();
    }

    final created = dao.create(Resource(resource.type, Uuid().v4(),
        attributes: resource.attributes,
        toMany: resource.toMany,
        toOne: resource.toOne));

    if (type == 'models') {
      // Insertion is artificially delayed
      final job = Job(Future.delayed(Duration(milliseconds: 100), () {
        dao.insert(created);
        return dao.toResource(created);
      }));
      _dao['jobs'].insert(job);
      return AcceptedResponse(_dao['jobs'].toResource(job));
    }

    dao.insert(created);

    return ResourceCreatedResponse(dao.toResource(created));
  }

  @override
  Response updateResource(String type, String id, Resource resource) {
    final dao = _getDaoOrThrow(type);

    _throwIfIncompatibleTypes(type, resource);
    if (dao.fetchById(id) == null) {
      return ErrorResponse.notFound(
          [JsonApiError(detail: 'Resource not found')]);
    }
    final updated = dao.update(id, resource);
    if (updated == null) {
      return NoContentResponse();
    }
    return ResourceUpdatedResponse(updated);
  }

  @override
  Response replaceToOne(
      String type, String id, String relationship, Identifier identifier) {
    final dao = _getDaoOrThrow(type);

    dao.replaceToOne(id, relationship, identifier);
    return NoContentResponse();
  }

  @override
  Response replaceToMany(String type, String id, String relationship,
      List<Identifier> identifiers) {
    final dao = _getDaoOrThrow(type);

    dao.replaceToMany(id, relationship, identifiers);
    return NoContentResponse();
  }

  @override
  Response addToMany(String type, String id, String relationship,
      List<Identifier> identifiers) {
    final dao = _getDaoOrThrow(type);

    return ToManyResponse(
        type, id, relationship, dao.addToMany(id, relationship, identifiers));
  }

  void _throwIfIncompatibleTypes(String type, Resource resource) {
    if (type != resource.type) {
      throw ErrorResponse.conflict([JsonApiError(detail: 'Incompatible type')]);
    }
  }

  DAO _getDaoOrThrow(String type) {
    if (_dao.containsKey(type)) return _dao[type];

    throw ErrorResponse.notFound(
        [JsonApiError(detail: 'Unknown resource type ${type}')]);
  }

  Resource _fetchResourceOrThrow(String type, String id) {
    final dao = _getDaoOrThrow(type);
    final resource = dao.fetchByIdAsResource(id);
    if (resource == null) {
      throw ErrorResponse.notFound(
          [JsonApiError(detail: 'Resource not found')]);
    }
    return resource;
  }

  Map<T, R> _filter<T, R>(Map<T, R> map, bool f(T t)) =>
      {...map}..removeWhere((k, _) => !f(k));
}
