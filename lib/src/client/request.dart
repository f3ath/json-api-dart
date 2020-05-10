import 'dart:convert';

import 'package:json_api/query.dart';
import 'package:json_api/src/client/content_type.dart';
import 'package:json_api/src/client/document.dart';
import 'package:json_api/src/http/http_method.dart';

/// A JSON:API request.
class Request {
  Request(this.method, {QueryParameters parameters})
      : headers = const {'Accept': ContentType.jsonApi},
        body = '',
        parameters = parameters ?? QueryParameters.empty();

  Request.withDocument(Object document, this.method,
      {QueryParameters parameters})
      : headers = const {
          'Accept': ContentType.jsonApi,
          'Content-Type': ContentType.jsonApi
        },
        body = jsonEncode(document),
        parameters = parameters ?? QueryParameters.empty();

  static Request fetch({Iterable<String> include = const []}) =>
      Request(HttpMethod.GET, parameters: Include(include));

  static Request createNewResource(String type,
          {Map<String, Object> attributes = const {},
          Map<String, Identifier> one = const {},
          Map<String, Iterable<Identifier>> many = const {}}) =>
      Request.withDocument(
          _Resource(type, attributes: attributes, one: one, many: many),
          HttpMethod.POST);

  static Request createResource(String type, String id,
          {Map<String, Object> attributes = const {},
          Map<String, Identifier> one = const {},
          Map<String, Iterable<Identifier>> many = const {}}) =>
      Request.withDocument(
          _Resource.withId(type, id,
              attributes: attributes, one: one, many: many),
          HttpMethod.POST);

  static Request updateResource(String type, String id,
          {Map<String, Object> attributes = const {},
          Map<String, Identifier> one = const {},
          Map<String, Iterable<Identifier>> many = const {}}) =>
      Request.withDocument(
          _Resource.withId(type, id,
              attributes: attributes, one: one, many: many),
          HttpMethod.PATCH);

  static Request deleteResource() => Request(HttpMethod.DELETE);

  static Request replaceOne(Identifier identifier) =>
      Request.withDocument(_One(identifier), HttpMethod.PATCH);

  static Request deleteOne() =>
      Request.withDocument(_One(null), HttpMethod.PATCH);

  static Request deleteMany(Iterable<Identifier> identifiers) =>
      Request.withDocument(_Many(identifiers), HttpMethod.DELETE);

  static Request replaceMany(Iterable<Identifier> identifiers) =>
      Request.withDocument(_Many(identifiers), HttpMethod.PATCH);

  static Request addMany(Iterable<Identifier> identifiers) =>
      Request.withDocument(_Many(identifiers), HttpMethod.POST);

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
      : _resource = {
          'type': type,
          if (attributes.isNotEmpty) 'attributes': attributes,
          ...relationship(one, many)
        };

  _Resource.withId(String type, String id,
      {Map<String, Object> attributes = const {},
      Map<String, Identifier> one = const {},
      Map<String, Iterable<Identifier>> many = const {}})
      : _resource = {
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

  final Object _resource;

  Map<String, Object> toJson() => {'data': _resource};
}

class _One {
  _One(this._ref);

  final Identifier _ref;

  Map<String, Object> toJson() => {'data': _ref};
}

class _Many {
  _Many(this._refs);

  final Iterable<Identifier> _refs;

  Map<String, Object> toJson() => {
        'data': _refs.toList(),
      };
}
