import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/resource_with_identity.dart';
import 'package:maybe_just_nothing/maybe_just_nothing.dart';

/// A generic response document
class Document {
  Document(dynamic json)
      : _json = json is Map<String, Object>
            ? json
            : throw ArgumentError('Invalid JSON');

  final Map _json;

  bool has(String key) => _json.containsKey(key);

  Maybe<dynamic> get(String key) => Maybe(_json[key]);

  Maybe<Map<String, Object>> meta() =>
      Maybe(_json['meta']).cast<Map<String, Object>>();

  Maybe<Map<String, Link>> links() => readPath<Map>(['links']).map((_) =>
      _.map((key, value) => MapEntry(key.toString(), Link.fromJson(value))));

  Maybe<List<ResourceWithIdentity>> included() => readPath<List>(['included'])
      .map((_) => _.map(ResourceWithIdentity.fromJson).toList());

  /// Returns the value at the [path] if both are true:
  /// - the path exists
  /// - the value is of type T
  Maybe<T> readPath<T>(List<String> path) => _path(path, Maybe(_json));

  Maybe<T> _path<T>(List<String> path, Maybe<Map> json) {
    if (path.isEmpty) throw ArgumentError('Empty path');
    final value = json.flatMap((_) => Maybe(_[path.first]));
    if (path.length == 1) return value.cast<T>();
    return _path<T>(path.sublist(1), value.cast<Map>());
  }
}
