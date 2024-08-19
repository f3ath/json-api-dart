import 'package:json_api/document.dart';

Object? documentEncoder(Object? v) => switch (v) {
      OutboundDocument() => v.toJson(),
      DateTime() => v.toIso8601String(),
      _ => throw UnsupportedError('Cannot convert to JSON: $v'),
    };
