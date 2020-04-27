import 'package:json_api/src/document/link.dart';

mixin Links {
  /// The `links` object.
  /// May be empty.
  /// https://jsonapi.org/format/#document-links
  final links = <String, Link>{};
}
