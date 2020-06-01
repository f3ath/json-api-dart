import 'package:json_api/document.dart';

class ResourceTarget {
  const ResourceTarget(this.type, this.id);

  static ResourceTarget fromIdentifier(Identifier identifier) =>
      ResourceTarget(identifier.type, identifier.id);

  final String type;

  final String id;
}
