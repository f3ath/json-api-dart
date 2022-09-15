import 'dart:collection';

import 'package:json_api/src/document/link.dart';

class Relationship<T> with IterableMixin<T> {
  final links = <String, Link>{};
  final meta = <String, Object?>{};

  Map<String, dynamic> toJson() => {
        if (links.isNotEmpty) 'links': links,
        if (meta.isNotEmpty) 'meta': meta,
      };

  @override
  Iterator<T> get iterator => <T>[].iterator;
}
