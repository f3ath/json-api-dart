import 'dart:async';

import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/json_api_error.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:json_api/src/server/_server.dart';
import 'package:uuid/uuid.dart';

import 'dao.dart';
import 'job_queue.dart';

class CarsController implements Controller {
  final Map<String, DAO> _dao;

  final _pagination = FixedSizePage(1);

  CarsController(this._dao);

  @override
  Response fetchCollection(
      CollectionTarget target, Map<String, List<String>> query) {
    final dao = _getDao(target.type);
    final page = Page.decode(query);
    final collection =
        dao.fetchCollection(_pagination.limit(page), _pagination.offset(page));
    return CollectionResponse(
        Collection(collection.elements.map(dao.toResource),
            total: collection.total),
        included: const []);
  }

  @override
  Response fetchRelated(RelatedTarget target, Map<String, List<String>> query) {
    final dao = _getDao(target.type);
    final page = Page.decode(query);

    final res = dao.fetchByIdAsResource(target.id);
    if (res == null) {
      return ErrorResponse.notFound(
          [JsonApiError(detail: 'Resource not found')]);
    }

    if (res.toOne.containsKey(target.relationship)) {
      final id = res.toOne[target.relationship];
      final resource = _dao[id.type].fetchByIdAsResource(id.id);
      return RelatedResourceResponse(resource);
    }

    if (res.toMany.containsKey(target.relationship)) {
      final relationships = res.toMany[target.relationship];
      final resources = relationships
          .skip(_pagination.offset(page))
          .take(_pagination.limit(page))
          .map((id) => _dao[id.type].fetchByIdAsResource(id.id));
      return RelatedCollectionResponse(
          Collection(resources, total: relationships.length),
          included: const []);
    }
    return ErrorResponse.notFound(
        [JsonApiError(detail: 'Relationship not found')]);
  }

  @override
  Response fetchResource(
      ResourceTarget target, Map<String, List<String>> query) {
    final dao = _getDao(target.type);

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
  Response fetchRelationship(
      RelationshipTarget target, Map<String, List<String>> query) {
    final dao = _getDao(target.type);

    final res = dao.fetchByIdAsResource(target.id);
    if (res == null) {
      return ErrorResponse.notFound(
          [JsonApiError(detail: 'Resource not found')]);
    }

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
    final dao = _getDao(target.type);

    final res = dao.fetchByIdAsResource(target.id);
    if (res == null) {
      return ErrorResponse.notFound(
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
    final dao = _getDao(target.type);

    if (target.type != resource.type) {
      return ErrorResponse.conflict(
          [JsonApiError(detail: 'Incompatible type')]);
    }

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
    final dao = _getDao(target.type);

    if (target.type != resource.type) {
      return ErrorResponse.conflict(
          [JsonApiError(detail: 'Incompatible type')]);
    }
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
    final dao = _getDao(target.type);

    dao.replaceToOne(target.id, target.relationship, identifier);
    return NoContentResponse();
  }

  @override
  Response replaceToMany(
      RelationshipTarget target, List<Identifier> identifiers) {
    final dao = _getDao(target.type);

    dao.replaceToMany(target.id, target.relationship, identifiers);
    return NoContentResponse();
  }

  @override
  Response addToMany(RelationshipTarget target, List<Identifier> identifiers) {
    final dao = _getDao(target.type);

    return ToManyResponse(
        target, dao.addToMany(target.id, target.relationship, identifiers));
  }

  DAO _getDao(String type) {
    if (_dao.containsKey(type)) return _dao[type];

    throw ErrorResponse.notFound(
        [JsonApiError(detail: 'Unknown resource type $type')]);
  }
}
