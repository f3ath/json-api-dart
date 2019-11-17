import 'package:json_api/src/document/decoding_exception.dart';

/// Details: https://jsonapi.org/format/#document-jsonapi-object
class Api {
  /// The JSON:API version.
  final String version;
  final Map<String, Object> meta;

  const Api({this.version, this.meta});

  static Api fromJson(Object json) {
    if (json is Map) {
      return Api(version: json['version'], meta: json['meta']);
    }
    throw DecodingException('Can not decode JsonApi from $json');
  }

  Map<String, Object> toJson() => {
        if (null != version) ...{'version': version},
        if (null != meta) ...{'meta': meta},
      };
}
