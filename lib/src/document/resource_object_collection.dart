import 'package:json_api/src/document/collection.dart';
import 'package:json_api/src/document/document.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/resource_object.dart';

class ResourceObjectCollection extends Collection<ResourceObject>
    implements PrimaryData {
  ResourceObjectCollection(
    Iterable<ResourceObject> elements,
  ) : super(elements);

  Map<String, Link> get links => {};

  toJson() => elements.toList();
}
