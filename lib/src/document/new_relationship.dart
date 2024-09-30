import 'dart:collection';

import 'package:json_api/src/document/json_encodable.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/new_identifier.dart';

class NewRelationship
    with IterableMixin<NewIdentifier>
    implements JsonEncodable {
  final links = <String, Link>{};
  final meta = <String, Object?>{};

  @override
  Map<String, dynamic> toJson() => {
        if (links.isNotEmpty) 'links': links,
        if (meta.isNotEmpty) 'meta': meta,
      };

  @override
  Iterator<NewIdentifier> get iterator => <NewIdentifier>[].iterator;
}
