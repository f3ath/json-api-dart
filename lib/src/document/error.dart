import 'link.dart';

/// [JsonApiError] is a JSON object representing an occurred on the server.
///
/// More on this: https://jsonapi.org/format/#errors
class JsonApiError {
  /// A unique identifier for this particular occurrence of the problem.
  String id;

  /// A link that leads to further details about this particular occurrence of the problem.
  Link about;

  /// The HTTP status code applicable to this problem, expressed as a string value.
  String status;

  /// An application-specific error code, expressed as a string value.
  String code;

  /// A short, human-readable summary of the problem that SHOULD NOT change
  /// from occurrence to occurrence of the problem, except for purposes of localization.
  String title;

  /// A human-readable explanation specific to this occurrence of the problem.
  /// Like title, this field’s value can be localized.
  String detail;

  /// A JSON Pointer [RFC6901] to the associated entity in the request document
  /// [e.g. "/data" for a primary data object, or "/data/attributes/title" for a specific attribute].
  String sourcePointer;

  /// A string indicating which URI query parameter caused the error.
  String sourceParameter;

  /// A meta object containing non-standard meta-information about the error.
  final meta = <String, Object>{};

  JsonApiError(
      {this.id,
      this.about,
      this.status,
      this.code,
      this.title,
      this.detail,
      this.sourceParameter,
      this.sourcePointer,
      Map<String, Object> meta}) {
    this.meta.addAll(meta ?? {});
  }

  static JsonApiError parse(Object json) {
    if (json is Map) {
      Link about;
      if (json['links'] is Map) about = Link.parse(json['links']['about']);

      String pointer;
      String parameter;
      if (json['source'] is Map) {
        parameter = json['source']['parameter'];
        pointer = json['source']['pointer'];
      }
      return JsonApiError(
          id: json['id'],
          about: about,
          status: json['status'],
          code: json['code'],
          title: json['title'],
          detail: json['detail'],
          sourcePointer: pointer,
          sourceParameter: parameter,
          meta: json['meta']);
    }
    throw 'Can not parse ErrorObject from $json';
  }

  Map<String, Object> toJson() {
    final json = <String, Object>{};
    if (id != null) json['id'] = id;
    if (status != null) json['status'] = status;
    if (code != null) json['code'] = code;
    if (title != null) json['title'] = title;
    if (detail != null) json['detail'] = detail;
    if (meta.isNotEmpty) json['meta'] = meta;
    if (about != null) json['links'] = {'about': about};
    final source = Map<String, String>();
    if (sourcePointer != null) source['pointer'] = sourcePointer;
    if (sourceParameter != null) source['parameter'] = sourceParameter;
    if (source.isNotEmpty) json['source'] = source;
    return json;
  }
}
