import 'dart:collection';

import 'package:json_api/src/document/document.dart';
import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/incomplete_relationship.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/many.dart';
import 'package:json_api/src/document/one.dart';

abstract class Relationship with IterableMixin<Identifier> {
  Relationship(
      {Map<String, Link> links = const {}, Map<String, Object> meta = const {}})
      : links = Map.unmodifiable(links ?? {}),
        meta = Map.unmodifiable(meta ?? {});

  /// Reconstructs a JSON:API Document or the `relationship` member of a Resource object.
  static Relationship fromJson(dynamic json) {
    final document = Document(json);
    final links = document.links().or(const {});
    final meta = document.meta().or(const {});
    if (document.has('data')) {
      final data = document.get('data').or(null);
      if (data == null) {
        return One.empty(links: links, meta: meta);
      }
      if (data is Map) {
        return One(Identifier.fromJson(data), links: links, meta: meta);
      }
      if (data is List) {
        return Many(data.map(Identifier.fromJson), links: links, meta: meta);
      }
      throw FormatException('Invalid relationship object');
    }

    return IncompleteRelationship(links: links, meta: meta);
  }

  final Map<String, Link> links;
  final Map<String, Object> meta;

  Map<String, Object> toJson() => {
        if (links.isNotEmpty) 'links': links,
        if (meta.isNotEmpty) 'meta': meta,
      };

  @override
  Iterator<Identifier> get iterator => const <Identifier>[].iterator;

  /// Narrows the type down to R if possible. Otherwise throws the [TypeError].
  R as<R extends Relationship>() => this is R ? this : throw TypeError();
}
