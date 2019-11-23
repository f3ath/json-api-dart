import 'package:json_api/src/url_design/collection_target.dart';

class ResourceTarget implements CollectionTarget {
  final String type;
  final String id;

  const ResourceTarget(this.type, this.id);

  @override
  bool operator ==(other) =>
      other is ResourceTarget && other.type == type && other.id == id;
}
