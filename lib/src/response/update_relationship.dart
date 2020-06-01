import 'dart:convert';

import 'package:json_api/src/document/relationship.dart';
import 'package:json_api_common/http.dart';
import 'package:maybe_just_nothing/maybe_just_nothing.dart';

class UpdateRelationship<R extends Relationship> {
  UpdateRelationship({R relationship}) : relationship = Maybe(relationship);

  static UpdateRelationship<R> decode<R extends Relationship>(
          HttpResponse http) =>
      Maybe(http.body)
          .filter((_) => _.isNotEmpty)
          .map(jsonDecode)
          .map(Relationship.fromJson)
          .cast<R>()
          .map((_) => UpdateRelationship(relationship: _))
          .orGet(() => UpdateRelationship());

  final Maybe<R> relationship;
}
