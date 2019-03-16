import 'package:json_api/src/document/document.dart';
import 'package:json_api/src/document/identifier_object.dart';
import 'package:json_api/src/document/identifier_object_collection.dart';

class Relationship<D extends ResourceLinkage> extends Document<D> {
  Relationship(D data) : super(data);

  static Relationship parse(Object json) =>
      _parse(json, ResourceLinkage.fromData);

  static Map<String, Relationship> parseMap(Map map) =>
      map.map((k, v) => MapEntry(k, parse(v)));

  static Relationship<IdentifierObjectCollection> parseToMany(Object json) =>
      _parse(json, IdentifierObjectCollection.fromData);

  static Relationship<IdentifierObject> parseToOne(Object json) =>
      _parse(json, IdentifierObject.fromData);

  static Relationship<D> _parse<D extends ResourceLinkage>(
      Object json, D parseData(Object json)) {
    if (json is Map) {
      return Relationship(parseData(json['data']));
    }
    throw 'Can not parse Relationship from $json';
  }
}

abstract class ResourceLinkage implements PrimaryData {
  static ResourceLinkage fromData(Object json) {
    if (json is Map || json == null) return IdentifierObject.fromData(json);
    if (json is List) return IdentifierObjectCollection.fromData(json);
    throw 'Can not parse RelationshipData from $json';
  }
}
