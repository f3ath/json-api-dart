import 'package:json_api/resource.dart';
import 'package:json_api/src/server/page.dart';

class Collection<T> {
  Iterable<T> elements;
  final Page page;

  Collection(this.elements, {this.page});
}

abstract class ResourceController {
  bool supports(String type);

  Future<Collection<Resource>> fetchCollection(
      String type, Map<String, String> params);

  Stream<Resource> fetchResources(Iterable<Identifier> ids);

  Future<void> createResource(Resource resource);

  Future<void> mergeToMany(
      Identifier resource, String rel, Iterable<Identifier> ids);
}
