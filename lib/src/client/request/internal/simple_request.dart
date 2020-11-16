import 'package:json_api/query.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/client/json_api_request.dart';
import 'package:json_api/src/http/media_type.dart';

abstract class SimpleRequest<T> implements JsonApiRequest<T> {
  SimpleRequest(this.method);

  Target get target;

  @override
  final String method;

  @override
  final body = '';

  @override
  final headers = <String, String>{'accept': MediaType.jsonApi};

  @override
  Uri uri(TargetMapper<Uri> urls) {
    final path = target.map(urls);
    return query.isEmpty
        ? path
        : path.replace(queryParameters: {...path.queryParameters, ...query});
  }

  /// URL Query String parameters
  final query = <String, String>{};

  /// Adds the request to include the [related] resources to the [query].
  void include(Iterable<String> related) {
    query.addAll(Include(related).asQueryParameters);
  }

  /// Adds the request for the sparse [fields] to the [query].
  void fields(Map<String, List<String>> fields) {
    query.addAll(Fields(fields).asQueryParameters);
  }

  /// Adds the request for pagination to the [query].
  void page(Map<String, String> page) {
    query.addAll(Page(page).asQueryParameters);
  }

  /// Adds the filter parameters to the [query].
  void filter(Map<String, String> page) {
    query.addAll(Filter(page).asQueryParameters);
  }

  /// Adds the request for page sorting to the [query].
  void sort(Iterable<String> fields) {
    query.addAll(Sort(fields).asQueryParameters);
  }
}
