import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/src/client/collection.dart';
import 'package:json_api/src/client/response/response.dart';

class FetchResponse extends Response {
  FetchResponse(HttpResponse http,
      {Iterable<Resource> included = const [],
      Map<String, Link> links = const {}})
      : super(http) {
    this.included.addAll(included);
    this.links.addAll(links);
  }

  /// Included resources
  final included = ResourceCollection();

  /// Links to iterate the collection
  final links = <String, Link>{};
}
