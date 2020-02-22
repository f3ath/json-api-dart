import 'package:json_api/src/document/api.dart';
import 'package:json_api/src/document/document_exception.dart';
import 'package:json_api/src/document/error_object.dart';
import 'package:json_api/src/document/json_encodable.dart';
import 'package:json_api/src/document/primary_data.dart';
import 'package:json_api/src/nullable.dart';

class Document<Data extends PrimaryData> implements JsonEncodable {
  /// Create a document with primary data
  Document(this.data, {Map<String, Object> meta, this.api})
      : errors = null,
        meta = (meta == null) ? null : Map.unmodifiable(meta);

  /// Create a document with errors (no primary data)
  Document.error(Iterable<ErrorObject> errors,
      {Map<String, Object> meta, this.api})
      : data = null,
        meta = (meta == null) ? null : Map.unmodifiable(meta),
        errors = List.unmodifiable(errors);

  /// Create an empty document (no primary data and no errors)
  Document.empty(Map<String, Object> meta, {this.api})
      : data = null,
        meta = (meta == null) ? null : Map.unmodifiable(meta),
        errors = null {
    ArgumentError.checkNotNull(meta);
  }

  /// Reconstructs a document with the specified primary data
  static Document<Data> fromJson<Data extends PrimaryData>(
      Object json, Data Function(Object json) primaryData) {
    if (json is Map) {
      final api = nullable(Api.fromJson)(json['jsonapi']);
      if (json.containsKey('errors')) {
        final errors = json['errors'];
        if (errors is List) {
          return Document.error(errors.map(ErrorObject.fromJson),
              meta: json['meta'], api: api);
        }
      } else if (json.containsKey('data')) {
        return Document(primaryData(json), meta: json['meta'], api: api);
      } else if (json['meta'] != null) {
        return Document.empty(json['meta'], api: api);
      }
      throw DocumentException('Unrecognized JSON:API document structure');
    }
    throw DocumentException('A JSON:API document must be a JSON object');
  }

  static const contentType = 'application/vnd.api+json';

  /// The Primary Data
  final Data data;

  /// The `jsonapi` object. May be null.
  final Api api;

  /// List of errors. May be null.
  final List<ErrorObject> errors;

  /// Meta data. May be empty or null.
  final Map<String, Object> meta;

  @override
  Map<String, Object> toJson() => {
        if (data != null)
          ...data.toJson()
        else if (errors != null) ...{'errors': errors},
        if (meta != null) ...{'meta': meta},
        if (api != null) ...{'jsonapi': api},
      };
}
