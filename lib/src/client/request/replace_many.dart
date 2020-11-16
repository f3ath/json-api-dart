import 'package:json_api/src/client/request/replace.dart';
import 'package:json_api/document.dart';
import 'package:json_api/routing.dart';

class ReplaceMany extends Replace<Many> {
  ReplaceMany(RelationshipTarget target, Many many) : super(target, many);

  ReplaceMany.build(String type, String id, String relationship,
      Iterable<Identifier> identifiers)
      : super.build(type, id, relationship, Many(identifiers));
}
