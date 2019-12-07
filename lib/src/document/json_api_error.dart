import 'package:json_api/src/document/decoding_exception.dart';
import 'package:json_api/src/document/link.dart';

/// [JsonApiError] represents an error occurred on the server.
///
/// More on this: https://jsonapi.org/format/#errors
class JsonApiError {
  /// A unique identifier for this particular occurrence of the problem.
  final String id;

  /// A link that leads to further details about this particular occurrence of the problem.
  Link get about => _links['about'];

  /// The HTTP status code applicable to this problem, expressed as a string value.
  final String status;

  /// An application-specific error code, expressed as a string value.
  final String code;

  /// A short, human-readable summary of the problem that SHOULD NOT change
  /// from occurrence to occurrence of the problem, except for purposes of localization.
  final String title;

  /// A human-readable explanation specific to this occurrence of the problem.
  /// Like title, this field’s value can be localized.
  final String detail;

  /// A JSON Pointer [RFC6901] to the associated entity in the query document
  /// [e.g. "/data" for a primary data object, or "/data/attributes/title" for a specific attribute].
  final String pointer;

  /// A string indicating which URI query parameter caused the error.
  final String parameter;

  /// A meta object containing non-standard meta-information about the error.
  final Map<String, Object> meta;

  final Map<String, Link> _links;

  /// Creates an instance of a JSON:API Error.
  /// The [links] map may contain custom links. The about link
  /// passed through the [about] argument takes precedence and will overwrite
  /// the `about` key in [links].
  JsonApiError({
    this.id,
    this.status,
    this.code,
    this.title,
    this.detail,
    this.parameter,
    this.pointer,
    this.meta,
    Link about,
    Map<String, Link> links = const {},
  }) : _links = {
          ...links,
          if (about != null) ...{'about': about}
        };

  /// All members of the `links` object, including non-standard links.
  /// This map is read-only.
  get links => Map.unmodifiable(_links);

  static JsonApiError fromJson(Object json) {
    if (json is Map) {
      String pointer;
      String parameter;
      if (json['source'] is Map) {
        parameter = json['source']['parameter'];
        pointer = json['source']['pointer'];
      }
      return JsonApiError(
          id: json['id'],
          status: json['status'],
          code: json['code'],
          title: json['title'],
          detail: json['detail'],
          pointer: pointer,
          parameter: parameter,
          meta: json['meta'],
          links: Link.fromJsonMap(json['links']));
    }
    throw DecodingException('Can not decode ErrorObject from $json');
  }

  Map<String, Object> toJson() {
    final source = {
      if (pointer != null) ...{'pointer': pointer},
      if (parameter != null) ...{'parameter': parameter},
    };
    return {
      if (id != null) ...{'id': id},
      if (status != null) ...{'status': status},
      if (code != null) ...{'code': code},
      if (title != null) ...{'title': title},
      if (detail != null) ...{'detail': detail},
      if (meta != null) ...{'meta': meta},
      if (_links.isNotEmpty) ...{'links': links},
      if (source.isNotEmpty) ...{'source': source},
    };
  }
}
