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

  static Request<d.ToOneObject> fetchOne(
          {Iterable<String> include = const []}) =>
      Request(HttpMethod.GET, d.ToOneObject.fromJson,
          parameters: Include(include));

  static Request<d.ToManyObject> fetchMany(
          {Iterable<String> include = const []}) =>
      Request(HttpMethod.GET, d.ToManyObject.fromJson,
          parameters: Include(include));

  static Request<d.RelationshipObject> fetchRelationship(
          {Iterable<String> include = const []}) =>
      Request(HttpMethod.GET, d.RelationshipObject.fromJson,
          parameters: Include(include));

  static Request<d.ResourceData> createNewResource(String type,
          {Map<String, Object> attributes = const {},
          Map<String, Identifier> one = const {},
          Map<String, Iterable<Identifier>> many = const {}}) =>
      Request.withDocument(
          _Resource(type, attributes: attributes, one: one, many: many),
          HttpMethod.POST,
          d.ResourceData.fromJson);

  static Request<d.ResourceData> createResource(String type, String id,
          {Map<String, Object> attributes = const {},
          Map<String, Identifier> one = const {},
          Map<String, Iterable<Identifier>> many = const {}}) =>
      Request.withDocument(
          _Resource.withId(type, id,
              attributes: attributes, one: one, many: many),
          HttpMethod.POST,
          d.ResourceData.fromJson);

  static Request<d.ResourceData> updateResource(String type, String id,
          {Map<String, Object> attributes = const {},
          Map<String, Identifier> one = const {},
          Map<String, Iterable<Identifier>> many = const {}}) =>
      Request.withDocument(
          _Resource.withId(type, id,
              attributes: attributes, one: one, many: many),
          HttpMethod.PATCH,
          d.ResourceData.fromJson);

  static Request<d.ResourceData> deleteResource() =>
      Request(HttpMethod.DELETE, d.ResourceData.fromJson);

  static Request<d.ToOneObject> replaceOne(Identifier identifier) =>
      Request.withDocument(
          _One(identifier), HttpMethod.PATCH, d.ToOneObject.fromJson);

  static Request<d.ToOneObject> deleteOne() => Request.withDocument(
      _One(null), HttpMethod.PATCH, d.ToOneObject.fromJson);

  static Request<d.ToManyObject> deleteMany(Iterable<Identifier> identifiers) =>
      Request.withDocument(
          _Many(identifiers), HttpMethod.DELETE, d.ToManyObject.fromJson);

  static Request<d.ToManyObject> replaceMany(
          Iterable<Identifier> identifiers) =>
      Request.withDocument(
          _Many(identifiers), HttpMethod.PATCH, d.ToManyObject.fromJson);

  static Request<d.ToManyObject> addMany(Iterable<Identifier> identifiers) =>
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
      Map<String, Identifier> one = const {},
      Map<String, Iterable<Identifier>> many = const {}})
      : _data = {
          'type': type,
          if (attributes.isNotEmpty) 'attributes': attributes,
          ...relationship(one, many)
        };

  _Resource.withId(String type, String id,
      {Map<String, Object> attributes = const {},
      Map<String, Identifier> one = const {},
      Map<String, Iterable<Identifier>> many = const {}})
      : _data = {
          'type': type,
          'id': id,
          if (attributes.isNotEmpty) 'attributes': attributes,
          ...relationship(one, many)
        };

  static Map<String, Object> relationship(Map<String, Identifier> one,
          Map<String, Iterable<Identifier>> many) =>
      {
        if (one.isNotEmpty || many.isNotEmpty)
          'relationships': {
            ...one.map((key, value) => MapEntry(key, _One(value))),
            ...many.map((key, value) => MapEntry(key, _Many(value)))
          }
      };

  final Object _data;

  Map<String, Object> toJson() => {'data': _data};
}

class _One {
  _One(this._identifier);

  final Identifier _identifier;

  Map<String, Object> toJson() => {'data': _identifier};
}

class _Many {
  _Many(this._identifiers);

  final Iterable<Identifier> _identifiers;

  Map<String, Object> toJson() => {
        'data': _identifiers.toList(),
      };
}

class Identifier {
  Identifier(this.type, this.id) {
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
