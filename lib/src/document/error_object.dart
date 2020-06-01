import 'package:json_api/src/document/link.dart';
import 'package:maybe_just_nothing/maybe_just_nothing.dart';

/// [ErrorObject] represents an error occurred on the server.
///
/// More on this: https://jsonapi.org/format/#errors
class ErrorObject {
  /// Creates an instance of a JSON:API Error.
  /// The [links] map may contain custom links. The about link
  /// passed through the [links['about']] argument takes precedence and will overwrite
  /// the `about` key in [links].
  ErrorObject({
    String id = '',
    String status = '',
    String code = '',
    String title = '',
    String detail = '',
    Map<String, Object> meta = const {},
    String sourceParameter = '',
    String sourcePointer = '',
    Map<String, Link> links = const {},
  })  : id = id ?? '',
        status = status ?? '',
        code = code ?? '',
        title = title ?? '',
        detail = detail ?? '',
        sourcePointer = sourcePointer ?? '',
        sourceParameter = sourceParameter ?? '',
        meta = Map.unmodifiable(meta ?? {}),
        links = Map.unmodifiable(links ?? {});

  static ErrorObject fromJson(dynamic json) {
    if (json is Map) {
      final source = Maybe(json['source']).cast<Map>().or(const {});
      return ErrorObject(
          id: Maybe(json['id']).cast<String>().or(''),
          status: Maybe(json['status']).cast<String>().or(''),
          code: Maybe(json['code']).cast<String>().or(''),
          title: Maybe(json['title']).cast<String>().or(''),
          detail: Maybe(json['detail']).cast<String>().or(''),
          sourceParameter: Maybe(source['parameter']).cast<String>().or(''),
          sourcePointer: Maybe(source['pointer']).cast<String>().or(''),
          meta: Maybe(json['meta']).cast<Map<String, Object>>().or(const {}),
          links: Link.mapFromJson(json['links']));
    }
    throw FormatException('A JSON:API error must be a JSON object');
  }

  /// A unique identifier for this particular occurrence of the problem.
  /// May be empty.
  final String id;

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

  /// A JSON Pointer (RFC6901) to the associated entity in the request document,
  ///   e.g. "/data" for a primary data object, or "/data/attributes/title" for a specific attribute.
  final String sourcePointer;

  /// A string indicating which URI query parameter caused the error.
  final String sourceParameter;

  /// Meta data.
  final Map<String, Object> meta;

  /// Error links. May be empty.
  final Map<String, Link> links;
}
