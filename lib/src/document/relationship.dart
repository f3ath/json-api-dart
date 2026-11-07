import 'dart:collection';

import 'package:json_api/src/document/json_encodable.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/new_identifier.dart';

class Relationship() with IterableMixin<Identifier> implements JsonEncodable {
  final links = <String, Link>{};
  final meta = <String, Object?>{};

  @override
  Map<String, Object?> toJson() => {
    if (links.isNotEmpty) 'links': links,
    if (meta.isNotEmpty) 'meta': meta,
  };

  @override
  Iterator<Identifier> get iterator => <Identifier>[].iterator;
}

class ToMany(Iterable<Identifier> identifiers) extends Relationship {
  this {
    _ids.addAll(identifiers);
  }

  final _ids = <Identifier>[];

  @override
  Map<String, Object?> toJson() => {
    'data': [..._ids],
    ...super.toJson(),
  };

  @override
  Iterator<Identifier> get iterator => _ids.iterator;
}

class ToOne(final Identifier? identifier) extends Relationship {
  new empty() : this(null);

  @override
  Map<String, Object?> toJson() => {'data': identifier, ...super.toJson()};

  @override
  Iterator<Identifier> get iterator => identifier == null ? super.iterator : [identifier!].iterator;
}
