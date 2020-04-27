import 'package:json_api/src/document/document_exception.dart';

/// Details: https://jsonapi.org/format/#document-jsonapi-object
class Api {
  Api({String version, Map<String, Object> meta})
      : meta = Map.unmodifiable(meta ?? const {}),
        version = version ?? '';

  /// The JSON:API version. May be null.
  final String version;

  /// Meta data. May be empty or null.
  final Map<String, Object> meta;

  bool get isNotEmpty => version.isNotEmpty || meta.isNotEmpty;

  static Api fromJson(Object json) {
    if (json is Map) {
      return Api(version: json['version'], meta: json['meta']);
    }
    throw DocumentException("The 'jsonapi' member must be a JSON object");
  }

  Map<String, Object> toJson() => {
        if (version.isNotEmpty) 'version': version,
        if (meta.isNotEmpty) 'meta': meta,
      };
}
