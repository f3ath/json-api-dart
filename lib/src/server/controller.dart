import 'dart:async';

import 'package:json_api/src/server/request.dart';

abstract class JsonApiController {
  Future fetchCollection(FetchCollection request);

  Future fetchRelated(FetchRelated request);

  Future fetchResource(FetchResource request);

  Future fetchRelationship(FetchRelationship request);

  Future deleteResource(DeleteResource request);

  Future createResource(CreateResource request);

  Future updateResource(UpdateResource request);

  Future replaceRelationship(ReplaceRelationship request);

  Future addToRelationship(AddToRelationship request);
}
