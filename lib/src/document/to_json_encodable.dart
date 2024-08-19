import 'package:json_api/document.dart';

/// A helper function to be used in `toJsonEncodable`
/// parameter of `jsonEncode()`.
Object? toJsonEncodable(Object? v) => switch (v) {
      JsonEncodable() => v.toJson(),
      DateTime() => v.toIso8601String(),
      _ => throw UnsupportedError('Cannot convert to JSON: $v'),
    };
