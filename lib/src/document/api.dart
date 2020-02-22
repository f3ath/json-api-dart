import 'package:json_api/src/document/document_exception.dart';
import 'package:json_api/src/document/json_encodable.dart';

/// Details: https://jsonapi.org/format/#document-jsonapi-object
class Api implements JsonEncodable {
  Api({this.version, Map<String, Object> meta})
      : meta = meta == null ? null : Map.unmodifiable(meta);

  /// The JSON:API version. May be null.
  final String version;

  /// Meta data. May be empty or null.
  final Map<String, Object> meta;

  static Api fromJson(Object json) {
    if (json is Map) {
      return Api(version: json['version'], meta: json['meta']);
    }
    throw DocumentException("The 'jsonapi' member must be a JSON object");
  }

  @override
  Map<String, Object> toJson() => {
        if (version != null) ...{'version': version},
        if (meta != null) ...{'meta': meta},
      };
}
