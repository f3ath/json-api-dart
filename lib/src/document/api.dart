import 'package:json_api/src/document/decoding_exception.dart';

/// Details: https://jsonapi.org/format/#document-jsonapi-object
class Api {
  /// The JSON:API version. May be null.
  final String version;

  /// Meta data. May be empty or null.
  final Map<String, Object> meta;

  Api({this.version, Map<String, Object> meta})
      : meta = meta == null ? null : Map.unmodifiable(meta);

  static Api fromJson(Object json) {
    if (json is Map) {
      return Api(version: json['version'], meta: json['meta']);
    }
    throw DecodingException<Api>(json);
  }

  Map<String, Object> toJson() => {
        if (version != null) ...{'version': version},
        if (meta != null) ...{'meta': meta},
      };
}
