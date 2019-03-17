import 'package:json_api/src/document/error.dart';
import 'package:json_api/src/document/primary_data.dart';
import 'package:json_api/src/document/resource_json.dart';

class Document<Data extends PrimaryData> {
  /// The Primary Data
  final Data data;

  /// For Compound Documents this member contains the included resources
  final List<ResourceJson> included;

  final List<JsonApiError> errors;
  final Map<String, Object> meta;

  Document(this.data,
      {Map<String, Object> meta, Iterable<ResourceJson> included})
      : this.errors = null,
        this.included =
            (included == null || included.isEmpty ? null : List.from(included)),
        this.meta = (meta == null || meta.isEmpty ? null : Map.from(meta));

  Document.error(Iterable<JsonApiError> errors, {Map<String, Object> meta})
      : this.data = null,
        this.included = null,
        this.errors = List.from(errors),
        this.meta = (meta == null || meta.isEmpty ? null : Map.from(meta));

  Document.empty(Map<String, Object> meta)
      : this.data = null,
        this.errors = null,
        this.included = null,
        this.meta = (meta == null || meta.isEmpty ? null : Map.from(meta)) {
    ArgumentError.checkNotNull(meta, 'meta');
  }

  static Document<Data> parse<Data extends PrimaryData>(
      Object json, Data parsePrimaryData(Object json)) {
    if (json is Map) {
      // TODO: validate `meta`
      if (json.containsKey('errors')) {
        final errors = json['errors'];
        if (errors is List) {
          return Document.error(errors.map(JsonApiError.parse),
              meta: json['meta']);
        }
      } else if (json.containsKey('data')) {
        final included = json['included'];
        final resources = <ResourceJson>[];
        if (included is List) {
          resources.addAll(included.map(ResourceJson.parse));
        }
        return Document(parsePrimaryData(json),
            meta: json['meta'],
            included: resources.isNotEmpty ? resources : null);
      } else {
        return Document.empty(json['meta']);
      }
    }
    throw 'Can not parse Document from $json';
  }

  Map<String, Object> toJson() {
    Map<String, Object> json = {};
    if (data != null) {
      json = data.toJson();
      if (included != null && included.isNotEmpty) {
        json['included'] = included;
      }
    } else if (errors != null) {
      json = {'errors': errors};
    }
    if (meta != null && meta.isNotEmpty) {
      json['meta'] = meta;
    }
    // TODO: add `jsonapi` member
    return json;
  }
}
