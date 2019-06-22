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
  final PageFactory _page;

  CarsController(this._dao, this._page);

  @override
  Response fetchCollection(
      FetchCollectionRequest request, Map<String, List<String>> query) {
    final dao = _getDao(request.target.type);
    final page = _page(query);
    final collection = dao.fetchCollection(page);
    return CollectionResponse(collection.map(dao.toResource),
        included: const [], page: page);
  }

  @override
  Response fetchRelated(
      FetchRelatedRequest request, Map<String, List<String>> query) {
    final dao = _getDao(request.target.type);

    final res = dao.fetchByIdAsResource(request.target.id);
    if (res == null) {
      return ErrorResponse.notFound(
          [JsonApiError(detail: 'Resource not found')]);
    }

    if (res.toOne.containsKey(request.target.relationship)) {
      final id = res.toOne[request.target.relationship];
      final resource = _dao[id.type].fetchByIdAsResource(id.id);
      return RelatedResourceResponse(resource);
    }

    if (res.toMany.containsKey(request.target.relationship)) {
      final page = _page(query);
      final relationships = res.toMany[request.target.relationship];
      final resources = relationships
          .skip(page.offset)
          .take(page.limit)
          .map((id) => _dao[id.type].fetchByIdAsResource(id.id));
      return RelatedCollectionResponse(
          Collection(resources, total: relationships.length),
          included: const [],
          page: page);
    }
    return ErrorResponse.notFound(
        [JsonApiError(detail: 'Relationship not found')]);
  }

  @override
  Response fetchResource(
      FetchResourceRequest request, Map<String, List<String>> query) {
    final dao = _getDao(request.target.type);

    final obj = dao.fetchById(request.target.id);

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
      FetchRelationshipRequest request, Map<String, List<String>> query) {
    final dao = _getDao(request.target.type);

    final res = dao.fetchByIdAsResource(request.target.id);
    if (res == null) {
      return ErrorResponse.notFound(
          [JsonApiError(detail: 'Resource not found')]);
    }

    if (res.toOne.containsKey(request.target.relationship)) {
      final id = res.toOne[request.target.relationship];
      return ToOneResponse(request.target, id);
    }

    if (res.toMany.containsKey(request.target.relationship)) {
      final ids = res.toMany[request.target.relationship];
      return ToManyResponse(request.target, ids);
    }
    return ErrorResponse.notFound(
        [JsonApiError(detail: 'Relationship not found')]);
  }

  @override
  Response deleteResource(DeleteResourceRequest request) {
    final dao = _getDao(request.target.type);

    final res = dao.fetchByIdAsResource(request.target.id);
    if (res == null) {
      return ErrorResponse.notFound(
          [JsonApiError(detail: 'Resource not found')]);
    }
    final dependenciesCount = dao.deleteById(request.target.id);
    if (dependenciesCount == 0) {
      return NoContentResponse();
    }
    return MetaResponse({'dependenciesCount': dependenciesCount});
  }

  @override
  Response createResource(CreateResourceRequest request, Resource resource) {
    final dao = _getDao(request.target.type);

    if (request.target.type != resource.type) {
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

    if (request.target.type == 'models') {
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
  Response updateResource(UpdateResourceRequest request, Resource resource) {
    final dao = _getDao(request.target.type);

    if (request.target.type != resource.type) {
      return ErrorResponse.conflict(
          [JsonApiError(detail: 'Incompatible type')]);
    }
    if (dao.fetchById(request.target.id) == null) {
      return ErrorResponse.notFound(
          [JsonApiError(detail: 'Resource not found')]);
    }
    final updated = dao.update(request.target.id, resource);
    if (updated == null) {
      return NoContentResponse();
    }
    return ResourceUpdatedResponse(updated);
  }

  @override
  Response replaceToOne(
      UpdateRelationshipRequest request, Identifier identifier) {
    final dao = _getDao(request.target.type);

    dao.replaceToOne(
        request.target.id, request.target.relationship, identifier);
    return NoContentResponse();
  }

  @override
  Response replaceToMany(
      UpdateRelationshipRequest request, List<Identifier> identifiers) {
    final dao = _getDao(request.target.type);

    dao.replaceToMany(
        request.target.id, request.target.relationship, identifiers);
    return NoContentResponse();
  }

  @override
  Response addToMany(AddToManyRequest request, List<Identifier> identifiers) {
    final dao = _getDao(request.target.type);

    return ToManyResponse(
        request.target,
        dao.addToMany(
            request.target.id, request.target.relationship, identifiers));
  }

  DAO _getDao(String type) {
    if (_dao.containsKey(type)) return _dao[type];

    throw ErrorResponse.notFound(
        [JsonApiError(detail: 'Unknown resource type $type')]);
  }
}
