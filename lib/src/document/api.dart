import 'package:json_api/src/document/document_exception.dart';
import 'package:json_api/src/document/meta.dart';

/// Details: https://jsonapi.org/format/#document-jsonapi-object
class Api with Meta {
  Api({String version, Map<String, Object> meta}) : version = version ?? v1 {
    this.meta.addAll(meta ?? {});
  }

  static const v1 = '1.0';

  /// The JSON:API version. May be null.
  final String version;

  bool get isNotEmpty => version.isNotEmpty || meta.isNotEmpty;

  static Api fromJson(Object json) {
    if (json is Map) {
      return Api(version: json['version'], meta: json['meta']);
    }
    throw DocumentException("The 'jsonapi' member must be a JSON object");
  }

  Map<String, Object> toJson() => {
        if (version != v1) 'version': version,
        if (meta.isNotEmpty) 'meta': meta,
      };
}
