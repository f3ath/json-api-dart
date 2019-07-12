import 'dart:convert';

/// Strips types from a json object.
/// This way we can simulate real world use cases when JSON comes in a string
/// rather than a Dart object, thus having information about types inside the JSON.
recodeJson(j) => json.decode(json.encode(j));
