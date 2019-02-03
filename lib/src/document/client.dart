import 'package:json_api/document.dart';

abstract class DocumentClient {
  Future<CollectionDocument> fetchCollection(Uri uri);

  Future<ResourceDocument> fetchResource(Uri uri);
}
