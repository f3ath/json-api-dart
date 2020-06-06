import 'package:json_api/src/document/api.dart';
import 'package:json_api/src/document/document_exception.dart';
import 'package:json_api/src/document/error_object.dart';
import 'package:json_api/src/document/json_encodable.dart';
import 'package:json_api/src/document/primary_data.dart';
import 'package:json_api/src/nullable.dart';

class Document<Data extends PrimaryData> implements JsonEncodable {
  /// Create a document with primary data
  Document(this.data, {Map<String, Object> meta, Api api})
      : errors = const [],
        meta = Map.unmodifiable(meta ?? const {}),
        api = api ?? Api(),
        isError = false,
        isMeta = false {
    ArgumentError.checkNotNull(data);
  }

  /// Create a document with errors (no primary data)
  Document.error(Iterable<ErrorObject> errors,
      {Map<String, Object> meta, Api api})
      : data = null,
        meta = Map.unmodifiable(meta ?? const {}),
        errors = List.unmodifiable(errors ?? const []),
        api = api ?? Api(),
        isError = true,
        isMeta = false;

  /// Create an empty document (no primary data and no errors)
  Document.empty(Map<String, Object> meta, {Api api})
      : data = null,
        meta = Map.unmodifiable(meta ?? const {}),
        errors = const [],
        api = api ?? Api(),
        isError = false,
        isMeta = true {
    ArgumentError.checkNotNull(meta);
  }

  /// The Primary Data. May be null.
  final Data data;

  /// List of errors. May be empty or null.
  final List<ErrorObject> errors;

  /// Meta data. May be empty.
  final Map<String, Object> meta;

  /// The `jsonapi` object.
  final Api api;

  /// True for error documents.
  final bool isError;

  /// True for non-error meta-only documents.
  final bool isMeta;

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
      } else if (primaryData != null) {
        return Document(primaryData(json), meta: json['meta'], api: api);
      } else if (json['meta'] != null) {
        return Document.empty(json['meta'], api: api);
      }
      throw DocumentException('Unrecognized JSON:API document structure');
    }
    throw DocumentException('A JSON:API document must be a JSON object');
  }

  static const contentType = 'application/vnd.api+json';

  @override
  Map<String, Object> toJson() => {
        if (data != null) ...data.toJson() else if (isError) 'errors': errors,
        if (isMeta || meta.isNotEmpty) 'meta': meta,
        if (api.isNotEmpty) 'jsonapi': api,
      };
}
