import 'package:json_api/core.dart';
import 'package:json_api/src/client/client.dart';
import 'package:json_api/src/client/response.dart';
import 'package:json_api/src/nullable.dart';
import 'package:json_api/src/transport/identifier_container.dart';
import 'package:json_api/src/transport/link.dart';
import 'package:json_api/src/transport/resource_document.dart';

abstract class Relationship {
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
        return ToMany(data.map(IdentifierContainer.fromJson).toList(),
            self: links['self'], related: links['related']);
      }
      return ToOne(nullable(json['data'], IdentifierContainer.fromJson),
          self: links['self'], related: links['related']);
    }
    throw 'Can not parse Relationship from $json';
  }
}

class ToMany extends Relationship {
  final List<IdentifierContainer> _data;

  ToMany(Iterable<IdentifierContainer> _data, {Link self, Link related})
      : _data = List.unmodifiable(_data),
        super._(self: self, related: related);

  List<Identifier> get identifiers => _data.map((_) => _.identifier).toList();
}

class ToOne extends Relationship {
  final IdentifierContainer _data;

  ToOne(this._data, {Link self, Link related})
      : super._(self: self, related: related);

  Identifier get identifier => _data.identifier;

  Future<Response<ResourceDocument>> fetchRelated(Client client) {
    if (self == null) throw StateError('The "self" link is null');
    return client.fetchResource(self.uri);
  }
}
