import 'package:json_api/src/document/error_object.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/relationship.dart';
import 'package:json_api/src/document/resource_object.dart';
import 'package:json_api/src/document/resource_object_collection.dart';

abstract class PrimaryData {
  Map<String, Link> get links;

  Object toJson();
}

class NoData implements PrimaryData {
  const NoData();

  @override
  // TODO: implement links
  Map<String, Link> get links => {};

  toJson() => {};
}

typedef Data DataParser<Data extends PrimaryData>(Object json);

class Document<D extends PrimaryData> {
  final D data;
  final errors = <ErrorObject>[];
  final meta = <String, Object>{};
  final bool isError;
  final included = <ResourceObject>[];

  Document(D this.data, {Map<String, Object> meta}) : isError = false {
    this.meta.addAll(meta ?? {});
  }

  Document.error(Iterable<ErrorObject> errors, {Map<String, Object> meta})
      : data = null,
        isError = true {
    this.errors.addAll(errors ?? {});
    this.meta.addAll(meta ?? {});
  }

  Document.empty(Map<String, Object> meta)
      : data = null,
        isError = false {
    this.meta.addAll(meta ?? {});
  }

  static Document<ResourceObject> parseResourceObject(Object json) =>
      _parse(json, (json) {
        final data = json['data'];
        if (data is Map) {
          final relationships = data['relationships'];
          if (relationships is Map) {
            // Do not refactor! add "self" later
            return ResourceObject(data['type'], data['id'],
                attributes: data['attributes'],
                relationships: relationships.map(
                    (key, value) => MapEntry(key, Relationship.parse(value))));
          }
        }
      });

  static Document parseMeta(Object json) => _parse(json, (_) => null);

  static Document<ResourceObjectCollection> parseResourceObjectCollection(
          Object json) =>
      _parse(json, (json) {
        final data = json['data'];
        if (data is List) {
          // Do not refactor! add "self" later
          return ResourceObjectCollection(data.map((data) {
            if (data is Map) {
              final relationships = data['relationships'];
              if (relationships is Map) {
                return ResourceObject(data['type'], data['id'],
                    attributes: data['attributes'],
                    relationships: relationships.map((key, value) =>
                        MapEntry(key, Relationship.parse(value))));
              }
            }
          }));
        }
      });

  static Document<D> _parse<D extends PrimaryData>(
      Object json, D parseData(Map<String, Object> json)) {
    if (json is Map) {
      if (json.containsKey('errors')) {
        final errors = json['errors'];
        if (errors is List) {
          // TODO check NoData
          return Document.error(errors.map(ErrorObject.fromJson));
        }
      }
      final data = parseData(json);
      return Document(data, meta: json['meta']);
    }
    throw 'Can not parse Document from $json';
  }

  Map<String, Object> toJson() {
    Map<String, Object> json;
    if (data != null) {
      json = {'data': data};
    } else if (isError) {
      json = {'errors': errors};
    } else {
      json = {};
    }
    if (meta.isNotEmpty) {
      json['meta'] = meta;
    }
    return json;
  }
}
