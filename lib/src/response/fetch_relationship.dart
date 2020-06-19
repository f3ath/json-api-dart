import 'dart:convert';

import 'package:json_api_common/document.dart';
import 'package:json_api_common/http.dart';

class FetchRelationship<R extends Relationship> {
  FetchRelationship(this.relationship);

  static FetchRelationship<R> decode<R extends Relationship>(
          HttpResponse http) =>
      FetchRelationship(Relationship.fromJson(jsonDecode(http.body)).as<R>());

  final R relationship;
}
