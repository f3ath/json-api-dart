import 'dart:collection';

import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/new_identifier.dart';

class Relationship with IterableMixin<Identifier> {
  final links = <String, Link>{};
  final meta = <String, Object?>{};

  Map<String, dynamic> toJson() => {
        if (links.isNotEmpty) 'links': links,
        if (meta.isNotEmpty) 'meta': meta,
      };

  @override
  Iterator<Identifier> get iterator => <Identifier>[].iterator;
}
