import 'package:json_api/src/document/error_object.dart';
import 'package:json_api/src/document/error_source.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/new_identifier.dart';
import 'package:json_api/src/document/new_relationship.dart';
import 'package:json_api/src/document/new_resource.dart';
import 'package:json_api/src/document/new_to_many.dart';
import 'package:json_api/src/document/new_to_one.dart';
import 'package:json_api/src/document/relationship.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:json_api/src/document/to_many.dart';
import 'package:json_api/src/document/to_one.dart';
import 'package:json_api/src/nullable.dart';

/// Inbound JSON:API document
class InboundDocument {
  InboundDocument(this.json);

  static const _parse = _Parser();

  /// Raw JSON object.
  final Map json;

  bool get hasData => json.containsKey('data');

  /// Included resources
  Iterable<Resource> included() => json
      .get<List>('included', orGet: () => [])
      .whereType<Map>()
      .map(_parse.resource);

  /// Top-level meta data.
  Map<String, Object?> meta() => _parse.meta(json);

  /// Top-level links object.
  Map<String, Link> links() => _parse.links(json);

  /// Errors (for an Error Document)
  Iterable<ErrorObject> errors() => json
      .get<List>('errors', orGet: () => [])
      .whereType<Map>()
      .map(_parse.errorObject);

  Iterable<Resource> dataAsCollection() =>
      _data<List>().whereType<Map>().map(_parse.resource);

  Resource dataAsResource() => _parse.resource(_data<Map>());

  NewResource dataAsNewResource() => _parse.newResource(_data<Map>());

  Resource? dataAsResourceOrNull() => nullable(_parse.resource)(_data<Map?>());

  ToMany asToMany() => asRelationship<ToMany>();

  ToOne asToOne() => asRelationship<ToOne>();

  R asRelationship<R extends Relationship>() {
    final rel = _parse.relationship(json);
    if (rel is R) return rel;
    throw FormatException('Invalid relationship type');
  }

  T _data<T>() => json.get<T>('data');
}

class _Parser {
  const _Parser();

  Map<String, Object?> meta(Map json) =>
      json.get<Map<String, Object?>>('meta', orGet: () => {});

  Map<String, Link> links(Map json) {
    var links = json.get<Map>('links', orGet: () => {});
    links.removeWhere((key, value) => value == null);
    return links.map((k, v) => MapEntry(k.toString(), _link(v)));
  }

  Relationship relationship(Map json) {
    final rel = json.containsKey('data') ? _rel(json['data']) : Relationship();
    rel.links.addAll(links(json));
    rel.meta.addAll(meta(json));
    return rel;
  }

  NewRelationship newRelationship(Map json) {
    final rel =
        json.containsKey('data') ? _newRel(json['data']) : NewRelationship();
    rel.links.addAll(links(json));
    rel.meta.addAll(meta(json));
    return rel;
  }

  Resource resource(Map json) => Resource(
        json.get<String>('type'),
        json.get<String>('id'),
      )
        ..attributes.addAll(_getAttributes(json))
        ..relationships.addAll(_getRelationships(json))
        ..links.addAll(links(json))
        ..meta.addAll(meta(json));

  NewResource newResource(Map json) => NewResource(
        json.get<String>('type'),
        id: json.getIfDefined('id'),
        lid: json.getIfDefined('lid'),
      )
        ..attributes.addAll(_getAttributes(json))
        ..relationships.addAll(_getNewRelationships(json))
        ..meta.addAll(meta(json));

  /// Decodes Identifier from [json]. Returns the decoded object.
  /// If the [json] has incorrect format, throws  [FormatException].
  Identifier identifier(Map json) =>
      Identifier(json.get<String>('type'), json.get<String>('id'))
        ..meta.addAll(meta(json));

  /// Decodes NewIdentifier from [json]. Returns the decoded object.
  /// If the [json] has incorrect format, throws  [FormatException].
  NewIdentifier newIdentifier(Map json) {
    final type = json.get<String>('type');
    final id = json.getIfDefined<String>('id');
    final lid = json.getIfDefined<String>('lid');
    if (id != null) {
      return Identifier(type, id)..meta.addAll(meta(json));
    }
    if (lid != null) {
      return LocalIdentifier(type, lid)..meta.addAll(meta(json));
    }
    throw FormatException('Invalid JSON');
  }

  ErrorObject errorObject(Map json) => ErrorObject(
      id: json.get<String>('id', orGet: () => ''),
      status: json.get<String>('status', orGet: () => ''),
      code: json.get<String>('code', orGet: () => ''),
      title: json.get<String>('title', orGet: () => ''),
      detail: json.get<String>('detail', orGet: () => ''),
      source: errorSource(json.get<Map>('source', orGet: () => {})))
    ..meta.addAll(meta(json))
    ..links.addAll(links(json));

  /// Decodes ErrorSource from [json]. Returns the decoded object.
  /// If the [json] has incorrect format, throws  [FormatException].
  ErrorSource errorSource(Map json) => ErrorSource(
      pointer: json.get<String>('pointer', orGet: () => ''),
      parameter: json.get<String>('parameter', orGet: () => ''));

  /// Decodes Link from [json]. Returns the decoded object.
  /// If the [json] has incorrect format, throws  [FormatException].
  Link _link(Object json) {
    if (json is String) return Link(Uri.parse(json));
    if (json is Map) {
      return Link(Uri.parse(json['href']))..meta.addAll(meta(json));
    }
    throw FormatException('Invalid JSON');
  }

  Map<String, Object?> _getAttributes(Map json) =>
      json.get<Map<String, Object?>>('attributes', orGet: () => {});

  Map<String, Relationship> _getRelationships(Map json) => json
      .get<Map>('relationships', orGet: () => {})
      .map((key, value) => MapEntry(key, relationship(value)));

  Map<String, NewRelationship> _getNewRelationships(Map json) => json
      .get<Map>('relationships', orGet: () => {})
      .map((key, value) => MapEntry(key, newRelationship(value)));

  Relationship _rel(data) {
    if (data == null) return ToOne.empty();
    if (data is Map) return ToOne(identifier(data));
    if (data is List) return ToMany(data.whereType<Map>().map(identifier));
    throw FormatException('Invalid relationship object');
  }

  NewRelationship _newRel(data) {
    if (data == null) {
      return NewToOne.empty();
    }
    if (data is Map) {
      return NewToOne(newIdentifier(data));
    }
    if (data is List) {
      return NewToMany(data.whereType<Map>().map(newIdentifier));
    }
    throw FormatException('Invalid relationship object');
  }
}

extension _TypedGeter on Map {
  T get<T>(String key, {T Function()? orGet}) {
    if (containsKey(key)) return _get(key);
    if (orGet != null) return orGet();
    throw FormatException('Key "$key" does not exist');
  }

  T? getIfDefined<T>(String key, {T Function()? orGet}) {
    if (containsKey(key)) return _get(key);
    return null;
  }

  T _get<T>(String key) {
    final val = this[key];
    if (val is T) return val;
    throw FormatException('Key "$key": expected $T, found ${val.runtimeType}');
  }
}
