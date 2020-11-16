import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:json_api/src/document/error_source.dart';
import 'package:json_api/src/document/many.dart';
import 'package:json_api/src/document/one.dart';
import 'package:json_api/src/extensions.dart';
import 'package:json_api/src/nullable.dart';

/// A generic inbound JSON:API document
class InboundDocument {
  InboundDocument(this._json) {
    included.addAll(_json
        .get<List>('included', orGet: () => [])
        .whereType<Map>()
        .map(_resource));

    errors.addAll(_json
        .get<List>('errors', orGet: () => [])
        .whereType<Map>()
        .map(_errorObject));

    meta.addAll(_meta(_json));

    links.addAll(_links(_json));
  }

  static InboundDocument decode(String body) {
    final json = jsonDecode(body);
    if (json is Map) return InboundDocument(json);
    throw FormatException('Invalid JSON body');
  }

  final Map _json;

  /// Included resources
  final included = <Resource>[];

  /// Error objects
  final errors = <ErrorObject>[];

  /// Document meta
  final meta = <String, Object /*?*/ >{};

  /// Document links
  final links = <String, Link>{};

  Iterable<Resource> resourceCollection() =>
      _json.get<List>('data').whereType<Map>().map(_resource);

  Resource resource() =>
      _resource(_json.get<Map<String, Object /*?*/ >>('data'));

  NewResource newResource() =>
      _newResource(_json.get<Map<String, Object /*?*/ >>('data'));

  Resource /*?*/ nullableResource() {
    return nullable(_resource)(_json.getNullable<Map>('data'));
  }

  Relationship dataAsRelationship() => _relationship(_json);

  static Map<String /*!*/, Link> _links(Map json) => json
      .get<Map>('links', orGet: () => {})
      .map((k, v) => MapEntry(k.toString(), _link(v)));

  static Relationship _relationship(Map json) {
    final links = _links(json);
    final meta = _meta(json);
    if (json.containsKey('data')) {
      final data = json['data'];
      if (data == null) {
        return One.empty()..links.addAll(links)..meta.addAll(meta);
      }
      if (data is Map) {
        return One(_identifier(data))..links.addAll(links)..meta.addAll(meta);
      }
      if (data is List) {
        return Many(data.whereType<Map>().map(_identifier))
          ..links.addAll(links)
          ..meta.addAll(meta);
      }
      throw FormatException('Invalid relationship object');
    }
    return Relationship()..links.addAll(links)..meta.addAll(meta);
  }

  static Map<String, Object /*?*/ > _meta(Map json) =>
      json.get<Map<String, Object /*?*/ >>('meta', orGet: () => {});

  static Resource _resource(Map json) =>
      Resource(json.get<String>('type'), json.get<String>('id'))
        ..attributes.addAll(_getAttributes(json))
        ..relationships.addAll(_getRelationships(json))
        ..links.addAll(_links(json))
        ..meta.addAll(_meta(json));

  static NewResource _newResource(Map json) => NewResource(
      json.get<String>('type'),
      json.get<String /*?*/ >('id', orGet: () => null))
    ..attributes.addAll(_getAttributes(json))
    ..relationships.addAll(_getRelationships(json))
    ..meta.addAll(_meta(json));

  /// Decodes Identifier from [json]. Returns the decoded object.
  /// If the [json] has incorrect format, throws  [FormatException].
  static Identifier _identifier(Map json) =>
      Identifier(json.get<String>('type'), json.get<String>('id'))
        ..meta.addAll(_meta(json));

  static ErrorObject _errorObject(Map json) => ErrorObject(
      id: json.get<String>('id', orGet: () => ''),
      status: json.get<String>('status', orGet: () => ''),
      code: json.get<String>('code', orGet: () => ''),
      title: json.get<String>('title', orGet: () => ''),
      detail: json.get<String>('detail', orGet: () => ''),
      source: _errorSource(json.get<Map>('source', orGet: () => {})))
    ..meta.addAll(_meta(json))
    ..links.addAll(_links(json));

  /// Decodes ErrorSource from [json]. Returns the decoded object.
  /// If the [json] has incorrect format, throws  [FormatException].
  static ErrorSource _errorSource(Map json) => ErrorSource(
      pointer: json.get<String>('pointer', orGet: () => ''),
      parameter: json.get<String>('parameter', orGet: () => ''));

  /// Decodes Link from [json]. Returns the decoded object.
  /// If the [json] has incorrect format, throws  [FormatException].
  static Link _link(Object json) {
    if (json is String) return Link(Uri.parse(json));
    if (json is Map) {
      return Link(Uri.parse(json['href']))..meta.addAll(_meta(json));
    }
    throw FormatException('Invalid JSON');
  }

  static Map<String, Object /*?*/ > _getAttributes(Map json) =>
      json.get<Map<String, Object /*?*/ >>('attributes', orGet: () => {});

  static Map<String, Relationship> _getRelationships(Map json) => json
      .get<Map>('relationships', orGet: () => {})
      .map((key, value) => MapEntry(key, _relationship(value)));
}
