import 'package:json_api/client.dart';
import 'package:json_api/document.dart';
import 'package:json_api/routing.dart';

class DeleteOne extends ReplaceOne {
  DeleteOne(RelationshipTarget target) : super(target, One.empty());

  DeleteOne.build(String type, String id, String relationship)
      : this(RelationshipTarget(type, id, relationship));
}
