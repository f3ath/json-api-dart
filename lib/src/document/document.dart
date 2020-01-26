import 'package:json_api/src/document/api.dart';
import 'package:json_api/src/document/document_exception.dart';
import 'package:json_api/src/document/json_api_error.dart';
import 'package:json_api/src/document/primary_data.dart';

class Document<Data extends PrimaryData> {
  static const contentType = 'application/vnd.api+json';

  /// The Primary Data
  final Data data;

  /// The jsonapi object. May be null.
  final Api api;

  /// List of errors. May be null.
  final Iterable<JsonApiError> errors;

  /// Meta data. May be empty or null.
  final Map<String, Object> meta;

  /// Create a document with primary data
  Document(this.data, {Map<String, Object> meta, this.api})
      : errors = null,
        meta = (meta == null) ? null : Map.unmodifiable(meta);

  /// Create a document with errors (no primary data)
  Document.error(Iterable<JsonApiError> errors,
      {Map<String, Object> meta, this.api})
      : data = null,
        meta = (meta == null) ? null : Map.unmodifiable(meta),
        errors = List.unmodifiable(errors);

  /// Create an empty document (no primary data and no errors)
  Document.empty(Map<String, Object> meta, {this.api})
      : data = null,
        meta = (meta == null) ? null : Map.unmodifiable(meta),
        errors = null {
    DocumentException.throwIfNull(meta, "The 'meta' member must not be null");
  }

  /// Reconstructs a document with the specified primary data
  static Document<Data> fromJson<Data extends PrimaryData>(
      Object json, Data Function(Object json) primaryData) {
    if (json is Map) {
      Api api;
      if (json.containsKey(Api.memberName)) {
        api = Api.fromJson(json[Api.memberName]);
      }
      if (json.containsKey('errors')) {
        final errors = json['errors'];
        if (errors is List) {
          return Document.error(errors.map(JsonApiError.fromJson),
              meta: json['meta'], api: api);
        }
      } else if (json.containsKey('data')) {
        return Document(primaryData(json), meta: json['meta'], api: api);
      } else {
        return Document.empty(json['meta'], api: api);
      }
    }
    throw DocumentException('A JSON:API document must be a JSON object');
  }

  Map<String, Object> toJson() => {
        if (data != null)
          ...data.toJson()
        else if (errors != null) ...{'errors': errors},
        if (meta != null) ...{'meta': meta},
        if (api != null) ...{'jsonapi': api},
      };
}
