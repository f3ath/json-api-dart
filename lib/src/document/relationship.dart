import 'dart:collection';

import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/link.dart';

class Relationship with IterableMixin<Identifier> {
  final links = <String, Link>{};
  final meta = <String, Object?>{};

  Map<String, dynamic> toJson() => {
        if (links.isNotEmpty) 'links': links,
        if (meta.isNotEmpty) 'meta': meta,
      };

  @override
  Iterator<Identifier> get iterator => const <Identifier>[].iterator;
}
