import 'dart:convert';

import 'package:json_api/document.dart' as d;
import 'package:json_api/query.dart';
import 'package:json_api/src/client/content_type.dart';
import 'package:json_api/src/http/http_method.dart';

/// A JSON:API request.
class Request<D extends d.PrimaryData> {
  Request(this.method, this.decoder, {QueryParameters parameters})
      : headers = const {'Accept': ContentType.jsonApi},
        body = '',
        parameters = parameters ?? QueryParameters.empty();

  Request.withDocument(Object document, this.method, this.decoder,
      {QueryParameters parameters})
      : headers = const {
          'Accept': ContentType.jsonApi,
          'Content-Type': ContentType.jsonApi
        },
        body = jsonEncode(document),
        parameters = parameters ?? QueryParameters.empty();

  static Request<d.ResourceCollectionData> fetchCollection(
          {Iterable<String> include = const []}) =>
      Request(HttpMethod.GET, d.ResourceCollectionData.fromJson,
          parameters: Include(include));

  static Request<d.ResourceData> fetchResource(
          {Iterable<String> include = const []}) =>
      Request(HttpMethod.GET, d.ResourceData.fromJson,
          parameters: Include(include));

  static Request<d.ToOneObject> fetchOne() =>
      Request(HttpMethod.GET, d.ToOneObject.fromJson);

  static Request<d.ToManyObject> fetchMany() =>
      Request(HttpMethod.GET, d.ToManyObject.fromJson);

  static Request<d.RelationshipObject> fetchRelationship() =>
      Request(HttpMethod.GET, d.RelationshipObject.fromJson);

  static Request<d.ResourceData> createNewResource(String type,
          {Map<String, Object> attributes = const {},
          Map<String, Ref> one = const {},
          Map<String, Iterable<Ref>> many = const {}}) =>
      Request.withDocument(
          _Resource(type, attributes: attributes, one: one, many: many),
          HttpMethod.POST,
          d.ResourceData.fromJson);

  static Request<d.ResourceData> createResource(String type, String id,
          {Map<String, Object> attributes = const {},
          Map<String, Ref> one = const {},
          Map<String, Iterable<Ref>> many = const {}}) =>
      Request.withDocument(
          _Resource.withId(type, id,
              attributes: attributes, one: one, many: many),
          HttpMethod.POST,
          d.ResourceData.fromJson);

  static Request<d.ResourceData> updateResource(String type, String id,
          {Map<String, Object> attributes = const {},
          Map<String, Ref> one = const {},
          Map<String, Iterable<Ref>> many = const {}}) =>
      Request.withDocument(
          _Resource.withId(type, id,
              attributes: attributes, one: one, many: many),
          HttpMethod.PATCH,
          d.ResourceData.fromJson);

  static Request<d.ResourceData> deleteResource() =>
      Request(HttpMethod.DELETE, d.ResourceData.fromJson);

  static Request<d.ToOneObject> replaceOne(Ref identifier) =>
      Request.withDocument(
          _One(identifier), HttpMethod.PATCH, d.ToOneObject.fromJson);

  static Request<d.ToOneObject> deleteOne() => Request.withDocument(
      _One(null), HttpMethod.PATCH, d.ToOneObject.fromJson);

  static Request<d.ToManyObject> deleteMany(Iterable<Ref> identifiers) =>
      Request.withDocument(
          _Many(identifiers), HttpMethod.DELETE, d.ToManyObject.fromJson);

  static Request<d.ToManyObject> replaceMany(Iterable<Ref> identifiers) =>
      Request.withDocument(
          _Many(identifiers), HttpMethod.PATCH, d.ToManyObject.fromJson);

  static Request<d.ToManyObject> addMany(Iterable<Ref> identifiers) =>
      Request.withDocument(
          _Many(identifiers), HttpMethod.POST, d.ToManyObject.fromJson);

  final d.PrimaryDataDecoder<D> decoder;
  final String method;
  final String body;
  final Map<String, String> headers;
  final QueryParameters parameters;
}

class _Resource {
  _Resource(String type,
      {Map<String, Object> attributes = const {},
      Map<String, Ref> one = const {},
      Map<String, Iterable<Ref>> many = const {}})
      : _resource = {
          'type': type,
          if (attributes.isNotEmpty) 'attributes': attributes,
          ...relationship(one, many)
        };

  _Resource.withId(String type, String id,
      {Map<String, Object> attributes = const {},
      Map<String, Ref> one = const {},
      Map<String, Iterable<Ref>> many = const {}})
      : _resource = {
          'type': type,
          'id': id,
          if (attributes.isNotEmpty) 'attributes': attributes,
          ...relationship(one, many)
        };

  static Map<String, Object> relationship(
          Map<String, Ref> one, Map<String, Iterable<Ref>> many) =>
      {
        if (one.isNotEmpty || many.isNotEmpty)
          'relationships': {
            ...one.map((key, value) => MapEntry(key, _One(value))),
            ...many.map((key, value) => MapEntry(key, _Many(value)))
          }
      };

  final Object _resource;

  Map<String, Object> toJson() => {'data': _resource};
}

class _One {
  _One(this._ref);

  final Ref _ref;

  Map<String, Object> toJson() => {'data': _ref};
}

class _Many {
  _Many(this._refs);

  final Iterable<Ref> _refs;

  Map<String, Object> toJson() => {
        'data': _refs.toList(),
      };
}

class Ref {
  Ref(this.type, this.id) {
    ArgumentError.checkNotNull(type, 'type');
    ArgumentError.checkNotNull(id, 'id');
  }

  final String type;

  final String id;

  Map<String, Object> toJson() => {
        'type': type,
        'id': id,
      };
}
