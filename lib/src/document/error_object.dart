import 'package:json_api/document.dart';
import 'package:json_api/src/document/document_exception.dart';
import 'package:json_api/src/document/json_encodable.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/nullable.dart';

/// [ErrorObject] represents an error occurred on the server.
///
/// More on this: https://jsonapi.org/format/#errors
class ErrorObject implements JsonEncodable {
  /// Creates an instance of a JSON:API Error.
  /// The [links] map may contain custom links. The about link
  /// passed through the [about] argument takes precedence and will overwrite
  /// the `about` key in [links].
  ErrorObject({
    String id,
    String status,
    String code,
    String title,
    String detail,
    Map<String, Object> meta,
    Map<String, Object> source,
    Map<String, Link> links,
  })  : id = id ?? '',
        status = status ?? '',
        code = code ?? '',
        title = title ?? '',
        detail = detail ?? '',
        source = Map.unmodifiable(source ?? const {}),
        links = Map.unmodifiable(links ?? const {}),
        meta = Map.unmodifiable(meta ?? const {});

  static ErrorObject fromJson(Object json) {
    if (json is Map) {
      final source = json['source'];
      return ErrorObject(
          id: json['id'],
          status: json['status'],
          code: json['code'],
          title: json['title'],
          detail: json['detail'],
          source: source is Map
              ? source.map(
                  (key, value) => MapEntry(key.toString(), value.toString()))
              : {},
          meta: json['meta'],
          links: nullable(Link.mapFromJson)(json['links']) ?? const {});
    }
    throw DocumentException('A JSON:API error must be a JSON object');
  }

  /// A unique identifier for this particular occurrence of the problem.
  /// May be empty.
  final String id;

  /// A link that leads to further details about this particular occurrence of the problem.
  /// May be empty.
  Link get about => links['about'];

  /// The HTTP status code applicable to this problem, expressed as a string value.
  /// May be empty.
  final String status;

  /// An application-specific error code, expressed as a string value.
  /// May be empty.
  final String code;

  /// A short, human-readable summary of the problem that SHOULD NOT change
  /// from occurrence to occurrence of the problem, except for purposes of localization.
  /// May be empty.
  final String title;

  /// A human-readable explanation specific to this occurrence of the problem.
  /// Like title, this field’s value can be localized.
  /// May be empty.
  final String detail;

  /// A meta object containing non-standard meta-information about the error.
  /// May be empty.
  final Map<String, Object> meta;

  /// The `links` object.
  /// May be empty.
  /// https://jsonapi.org/format/#document-links
  final Map<String, Link> links;

  /// The `source` object.
  /// An object containing references to the source of the error, optionally including any of the following members:
  /// - pointer: a JSON Pointer [RFC6901] to the associated entity in the request document,
  ///   e.g. "/data" for a primary data object, or "/data/attributes/title" for a specific attribute.
  /// - parameter: a string indicating which URI query parameter caused the error.
  final Map<String, String> source;

  @override
  Map<String, Object> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      if (status.isNotEmpty) 'status': status,
      if (code.isNotEmpty) 'code': code,
      if (title.isNotEmpty) 'title': title,
      if (detail.isNotEmpty) 'detail': detail,
      if (meta.isNotEmpty) 'meta': meta,
      if (links.isNotEmpty) 'links': links,
      if (source.isNotEmpty) 'source': source,
    };
  }
}
