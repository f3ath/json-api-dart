import 'package:json_api/src/document/decoding_exception.dart';

/// Details: https://jsonapi.org/format/#document-jsonapi-object
class Api {
  final String version;
  final Map<String, Object> meta;

  Api({this.version, this.meta});

  static Api decodeJson(Object json) {
    if (json is Map) {
      return Api(version: json['version'], meta: json['meta']);
    }
    throw DecodingException('Can not decode JsonApi from $json');
  }

  Map<String, Object> toJson() => {
        if (version != null) ...{'version': version},
        if (meta != null) ...{'meta': meta},
      };
}
