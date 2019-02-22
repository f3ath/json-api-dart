import 'package:json_api/resource.dart';
import 'package:json_api/src/client/client.dart';
import 'package:json_api/src/nullable.dart';
import 'package:json_api/src/transport/document.dart';
import 'package:json_api/src/transport/identifier_envelope.dart';
import 'package:json_api/src/transport/link.dart';
import 'package:json_api/src/transport/resource_envelope.dart';

abstract class Relationship implements Document {
  final Link self;
  final Link related;

  Object get _data;

  Relationship._({this.self, this.related});

  Map<String, Object> toJson() {
    final json = {'data': _data};
    final links = {'self': self, 'related': related}
      ..removeWhere((k, v) => v == null);
    if (links.isNotEmpty) {
      json['links'] = links;
    }
    return json;
  }

  static Map<String, Relationship> parseMap(Map map) =>
      map.map((k, v) => MapEntry(k, Relationship.fromJson(v)));

  static Relationship fromJson(Object json) {
    if (json is Map) {
      final links = Link.parseMap(json['links'] ?? {});

      final data = json['data'];
      if (data is List) {
        return ToMany(data.map(IdentifierEnvelope.fromJson).toList(),
            self: links['self'], related: links['related']);
      }
      return ToOne(nullable(IdentifierEnvelope.fromJson)(json['data']),
          self: links['self'], related: links['related']);
    }
    throw 'Can not parse Relationship from $json';
  }
}

class ToMany extends Relationship {
  final List<IdentifierEnvelope> _data;

  ToMany(Iterable<IdentifierEnvelope> _data, {Link self, Link related})
      : _data = List.unmodifiable(_data),
        super._(self: self, related: related);

  static ToMany fromJson(Object json) {
    if (json is Map) {
      final links = Link.parseMap(json['links'] ?? {});

      final data = json['data'];
      if (data is List) {
        return ToMany(data.map(IdentifierEnvelope.fromJson).toList(),
            self: links['self'], related: links['related']);
      }
    }
    throw 'Can not parse ToMany from $json';
  }

  List<Identifier> get identifiers =>
      _data.map((_) => _.toIdentifier()).toList();

  Future<List<ResourceEnvelope>> fetchRelated(Client client) async {
    if (related == null) throw StateError('The "related" link is null');
    final response = await client.fetchCollection(related.uri);
    if (response.isSuccessful) return response.document.collection;
    throw 'Error'; // TODO define exceptions
  }
}

class ToOne extends Relationship {
  final IdentifierEnvelope _data;

  ToOne(this._data, {Link self, Link related})
      : super._(self: self, related: related);

  static ToOne fromJson(Object json) {
    if (json is Map) {
      final links = Link.parseMap(json['links'] ?? {});

      return ToOne(nullable(IdentifierEnvelope.fromJson)(json['data']),
          self: links['self'], related: links['related']);
    }
    throw 'Can not parse ToOne from $json';
  }

  Identifier get identifier => _data.toIdentifier();

  Future<ResourceEnvelope> fetchRelated(Client client) async {
    if (related == null) throw StateError('The "related" link is null');
    final response = await client.fetchResource(related.uri);
    if (response.isSuccessful) return response.document.resourceEnvelope;
    throw 'Error'; // TODO define exceptions
  }
}
