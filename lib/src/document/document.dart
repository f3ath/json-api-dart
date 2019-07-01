import 'package:json_api/src/document/api.dart';
import 'package:json_api/src/document/decoding_exception.dart';
import 'package:json_api/src/document/json_api_error.dart';
import 'package:json_api/src/document/primary_data.dart';

class Document<Data extends PrimaryData> {
  /// The Primary Data
  final Data data;
  final Api api;
  final List<JsonApiError> errors;
  final Map<String, Object> meta;

  /// Create a document with primary data
  Document(this.data, {this.meta, this.api}) : this.errors = null;

  /// Create a document with errors (no primary data)
  Document.error(Iterable<JsonApiError> errors, {this.meta, this.api})
      : this.data = null,
        this.errors = List.from(errors);

  /// Create an empty document (no primary data and no errors)
  Document.empty(this.meta, {this.api})
      : this.data = null,
        this.errors = null {
    ArgumentError.checkNotNull(meta, 'meta');
  }

  /// Decodes a document with the specified primary data
  static Document<Data> decodeJson<Data extends PrimaryData>(
      Object json, Data decodePrimaryData(Object json)) {
    if (json is Map) {
      Api api;
      if (json.containsKey('jsonapi')) {
        api = Api.decodeJson(json['jsonapi']);
      }
      if (json.containsKey('errors')) {
        final errors = json['errors'];
        if (errors is List) {
          return Document.error(errors.map(JsonApiError.decodeJson),
              meta: json['meta'], api: api);
        }
      } else if (json.containsKey('data')) {
        return Document(decodePrimaryData(json), meta: json['meta'], api: api);
      } else {
        return Document.empty(json['meta'], api: api);
      }
    }
    throw DecodingException('Can not decode Document from $json');
  }

  Map<String, Object> toJson() => {
        if (data != null)
          ...data.toJson()
        else if (errors != null) ...{'errors': errors},
        if (meta != null) ...{'meta': meta},
        if (api != null) ...{'jsonapi': api},
      };
}
