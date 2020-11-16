import 'package:json_api/src/client/request/replace.dart';
import 'package:json_api/document.dart';
import 'package:json_api/routing.dart';

class ReplaceOne extends Replace<One> {
  ReplaceOne(RelationshipTarget target, One one) : super(target, one);

  ReplaceOne.build(
      String type, String id, String relationship, Identifier identifier)
      : super.build(type, id, relationship, One(identifier));
}
