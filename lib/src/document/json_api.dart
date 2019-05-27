import 'package:json_api/src/document/decoding_exception.dart';

/// Details: https://jsonapi.org/format/#document-jsonapi-object
class JsonApi {
  final String version;
  final Map<String, Object> meta;

  JsonApi({this.version, Map<String, Object> meta})
      : meta = meta == null ? null : Map.from(meta);

  static JsonApi fromJson(Object json) {
    if (json is Map) {
      return JsonApi(version: json['version'], meta: json['meta']);
    }
    throw DecodingException('Can not decode JsonApi from $json');
  }

  Map<String, Object> toJson() => {
        if (version != null) ...{'version': version},
        if (meta != null) ...{'meta': meta},
      };
}
