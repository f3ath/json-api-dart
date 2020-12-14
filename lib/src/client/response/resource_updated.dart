import 'package:json_api/document.dart';
import 'package:json_api/http.dart';

class ResourceUpdated {
  ResourceUpdated(this.http, Map? json) : resource = _resource(json);

  static Resource? _resource(Map? json) {
    if (json != null) {
      final doc = InboundDocument(json);
      if (doc.hasData) {
        return doc.dataAsResource();
      }
    }
  }

  final HttpResponse http;

  /// The created resource. Null for "204 No Content" responses.
  late final Resource? resource;
}
