/// Details: https://jsonapi.org/format/#document-jsonapi-object
class JsonApi {
  final String version;
  final Map<String, Object> meta;

  JsonApi({this.version, Map<String, Object> meta})
      : meta = meta == null ? null : Map.from(meta);

  Map<String, Object> toJson() => {
        if (version != null) ...{'version': version},
        if (meta != null) ...{'meta': meta},
      };
}
