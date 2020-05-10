import 'dart:convert';

import 'package:json_api/http.dart';
import 'package:json_api/query.dart';
import 'package:json_api/src/client/content_type.dart';
import 'package:json_api/src/client/document.dart';
import 'package:json_api/src/http/http_method.dart';
import 'package:json_api/src/maybe.dart';

class JsonApiRequest {
  JsonApiRequest(this._method, {Object document})
      : _body = Maybe(document).map(jsonEncode).or('');

  JsonApiRequest.fetch() : this(HttpMethod.GET);

  JsonApiRequest.createNewResource(String type,
      {Map<String, Object> attributes = const {},
      Map<String, Identifier> one = const {},
      Map<String, Iterable<Identifier>> many = const {}})
      : this(HttpMethod.POST,
            document:
                _Resource(type, attributes: attributes, one: one, many: many));

  JsonApiRequest.createResource(String type, String id,
      {Map<String, Object> attributes = const {},
      Map<String, Identifier> one = const {},
      Map<String, Iterable<Identifier>> many = const {}})
      : this(HttpMethod.POST,
            document: _Resource.withId(type, id,
                attributes: attributes, one: one, many: many));

  JsonApiRequest.updateResource(String type, String id,
      {Map<String, Object> attributes = const {},
      Map<String, Identifier> one = const {},
      Map<String, Iterable<Identifier>> many = const {}})
      : this(HttpMethod.PATCH,
            document: _Resource.withId(type, id,
                attributes: attributes, one: one, many: many));

  JsonApiRequest.deleteResource() : this(HttpMethod.DELETE);

  JsonApiRequest.replaceOne(Identifier identifier)
      : this(HttpMethod.PATCH, document: _One(identifier));

  JsonApiRequest.deleteOne() : this(HttpMethod.PATCH, document: _One(null));

  JsonApiRequest.deleteMany(Iterable<Identifier> identifiers)
      : this(HttpMethod.DELETE, document: _Many(identifiers));

  JsonApiRequest.replaceMany(Iterable<Identifier> identifiers)
      : this(HttpMethod.PATCH, document: _Many(identifiers));

  JsonApiRequest.addMany(Iterable<Identifier> identifiers)
      : this(HttpMethod.POST, document: _Many(identifiers));

  final String _method;
  final String _body;
  final _headers = <String, String>{};
  QueryParameters _parameters = QueryParameters.empty();

  void headers(Map<String, String> headers) {
    _headers.addAll(headers);
  }

  void include(Iterable<String> items) {
    _parameters &= Include(items);
  }

  HttpRequest toHttp(Uri uri) =>
      HttpRequest(_method, _parameters.addToUri(uri), body: _body, headers: {
        ..._headers,
        'Accept': ContentType.jsonApi,
        if (_body.isNotEmpty) 'Content-Type': ContentType.jsonApi
      });
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
