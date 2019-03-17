import 'package:json_api/src/document/error.dart';
import 'package:json_api/src/document/primary_data.dart';
import 'package:json_api/src/document/resource_json.dart';
import 'package:json_api/src/nullable.dart';

class Document<Data extends PrimaryData> {
  /// The Primary Data
  final Data data;

  /// For Compound Documents this member contains the included resources
  final included = <ResourceJson>[];

  final List<JsonApiError> errors;
  final Map<String, Object> meta;

  Document.data(Data data, {Map<String, Object> meta})
      : this._(data: data, meta: nullable((_) => Map.from(_))(meta));

  Document.error(Iterable<JsonApiError> errors, {Map<String, Object> meta})
      : this._(
            errors: List.from(errors),
            meta: nullable((_) => Map.from(_))(meta));

  Document.empty(Map<String, Object> meta) : this._(meta: Map.from(meta));

  Document._({this.data, this.errors, this.meta}) {
    if (data == null && errors == null && meta.isEmpty) {
      throw ArgumentError(
          'The `meta` member may not be empty for meta-only documents');
    }
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
        final data = parsePrimaryData(json);
        return Document.data(data, meta: json['meta']);
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
