import 'dart:async';

import 'package:json_api/server.dart';
import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/json_api_error.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:json_api/src/pagination/pagination.dart';
import 'package:uuid/uuid.dart';

import 'dao.dart';
import 'job_queue.dart';

class CarsController implements Controller {
  final Map<String, DAO> _dao;

  final Pagination _pagination;

  CarsController(this._dao, this._pagination);

  @override
  Response fetchCollection(CollectionTarget target, Query query) {
    final dao = _getDaoOrThrow(target);
    final collection = dao.fetchCollection(
        _pagination.limit(query.page), _pagination.offset(query.page));
    return CollectionResponse(collection.elements.map(dao.toResource),
        included: const [], total: collection.totalCount);
  }

  @override
  Response fetchRelated(RelationshipTarget target, Query query) {
    final res = _fetchResourceOrThrow(target);

    if (res.toOne.containsKey(target.relationship)) {
      final id = res.toOne[target.relationship];
      final resource = _dao[id.type].fetchByIdAsResource(id.id);
      return RelatedResourceResponse(resource);
    }

    if (res.toMany.containsKey(target.relationship)) {
      final relationships = res.toMany[target.relationship];
      final resources = relationships
          .skip(_pagination.offset(query.page))
          .take(_pagination.limit(query.page))
          .map((id) => _dao[id.type].fetchByIdAsResource(id.id));
      return RelatedCollectionResponse(resources,
          total: relationships.length, included: const []);
    }
    return ErrorResponse.notFound(
        [JsonApiError(detail: 'Relationship not found')]);
  }

  @override
  Response fetchResource(ResourceTarget target, Query query) {
    final dao = _getDaoOrThrow(target);

    final obj = dao.fetchById(target.id);

    if (obj == null) {
      return ErrorResponse.notFound(
          [JsonApiError(detail: 'Resource not found')]);
    }
    if (obj is Job && obj.resource != null) {
      return SeeOtherResponse(obj.resource);
    }

    final fetchById = (Identifier _) => _dao[_.type].fetchByIdAsResource(_.id);

    final res = dao.toResource(obj);
    final children = res.toOne.values
        .map(fetchById)
        .followedBy(res.toMany.values.expand((_) => _.map(fetchById)));

    return ResourceResponse(res, included: children);
  }

  @override
  Response fetchRelationship(RelationshipTarget target, Query query) {
    final res = _fetchResourceOrThrow(target);

    if (res.toOne.containsKey(target.relationship)) {
      final id = res.toOne[target.relationship];
      return ToOneResponse(target, id);
    }

    if (res.toMany.containsKey(target.relationship)) {
      final ids = res.toMany[target.relationship];
      return ToManyResponse(target, ids);
    }
    return ErrorResponse.notFound(
        [JsonApiError(detail: 'Relationship not found')]);
  }

  @override
  Response deleteResource(ResourceTarget target) {
    final dao = _getDaoOrThrow(target);

    final res = dao.fetchByIdAsResource(target.id);
    if (res == null) {
      throw ErrorResponse.notFound(
          [JsonApiError(detail: 'Resource not found')]);
    }
    final dependenciesCount = dao.deleteById(target.id);
    if (dependenciesCount == 0) {
      return NoContentResponse();
    }
    return MetaResponse({'dependenciesCount': dependenciesCount});
  }

  @override
  Response createResource(CollectionTarget target, Resource resource) {
    final dao = _getDaoOrThrow(target);

    _throwIfIncompatibleTypes(target, resource);

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

    if (target.type == 'models') {
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
  Response updateResource(ResourceTarget target, Resource resource) {
    final dao = _getDaoOrThrow(target);

    _throwIfIncompatibleTypes(target, resource);
    if (dao.fetchById(target.id) == null) {
      return ErrorResponse.notFound(
          [JsonApiError(detail: 'Resource not found')]);
    }
    final updated = dao.update(target.id, resource);
    if (updated == null) {
      return NoContentResponse();
    }
    return ResourceUpdatedResponse(updated);
  }

  @override
  Response replaceToOne(RelationshipTarget target, Identifier identifier) {
    final dao = _getDaoOrThrow(target);

    dao.replaceToOne(target.id, target.relationship, identifier);
    return NoContentResponse();
  }

  @override
  Response replaceToMany(
      RelationshipTarget target, List<Identifier> identifiers) {
    final dao = _getDaoOrThrow(target);

    dao.replaceToMany(target.id, target.relationship, identifiers);
    return NoContentResponse();
  }

  @override
  Response addToMany(RelationshipTarget target, List<Identifier> identifiers) {
    final dao = _getDaoOrThrow(target);

    return ToManyResponse(
        target, dao.addToMany(target.id, target.relationship, identifiers));
  }

  void _throwIfIncompatibleTypes(CollectionTarget target, Resource resource) {
    if (target.type != resource.type) {
      throw ErrorResponse.conflict([JsonApiError(detail: 'Incompatible type')]);
    }
  }

  DAO _getDaoOrThrow(CollectionTarget target) {
    if (_dao.containsKey(target.type)) return _dao[target.type];

    throw ErrorResponse.notFound(
        [JsonApiError(detail: 'Unknown resource type ${target.type}')]);
  }

  Resource _fetchResourceOrThrow(ResourceTarget target) {
    final dao = _getDaoOrThrow(target);
    final resource = dao.fetchByIdAsResource(target.id);
    if (resource == null) {
      throw ErrorResponse.notFound(
          [JsonApiError(detail: 'Resource not found')]);
    }
    return resource;
  }
}
