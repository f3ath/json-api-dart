import 'dart:collection';

import 'package:json_api/src/document/json_encodable.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/new_identifier.dart';

class Relationship with IterableMixin<Identifier> implements JsonEncodable {
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
