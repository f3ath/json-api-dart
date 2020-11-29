import 'package:json_api/src/document/error_source.dart';
import 'package:json_api/src/document/link.dart';

/// [ErrorObject] represents an error occurred on the server.
///
/// More on this: https://jsonapi.org/format/#errors
class ErrorObject {
  /// Creates an instance of a JSON:API Error.
  /// The [links] map may contain custom links. The about link
  /// passed through the [links['about']] argument takes precedence and will overwrite
  /// the `about` key in [links].
  ErrorObject(
      {this.id = '',
      this.status = '',
      this.code = '',
      this.title = '',
      this.detail = '',
      this.source = const ErrorSource()});

  /// A unique identifier for this particular occurrence of the problem.
  final String id;

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

  /// Error source.
  final ErrorSource source;

  /// Error links.
  final links = <String, Link>{};

  /// Meta data.
  final meta = <String, Object?>{};

  Map<String, Object> toJson() => {
        if (id.isNotEmpty) 'id': id,
        if (status.isNotEmpty) 'status': status,
        if (code.isNotEmpty) 'code': code,
        if (title.isNotEmpty) 'title': title,
        if (detail.isNotEmpty) 'detail': detail,
        if (source.isNotEmpty) 'source': source,
        if (links.isNotEmpty) 'links': links,
        if (meta.isNotEmpty) 'meta': meta,
      };

  @override
  String toString() => toJson().toString();
}
