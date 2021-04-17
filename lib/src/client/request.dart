import 'package:json_api/http.dart';
import 'package:json_api/query.dart';

/// JSON:API request consumed by the client
class Request with HttpHeaders {
  Request(this.method, [this.document]);

  Request.get() : this('get');

  Request.post([Object? document]) : this('post', document);

  Request.delete([Object? document]) : this('delete', document);

  Request.patch([Object? document]) : this('patch', document);

  /// HTTP method
  final String method;

  final Object? document;

  /// Query parameters
  final query = <String, String>{};

  /// Requests inclusion of related resources.
  /// See https://jsonapi.org/format/#fetching-includes
  void include(Iterable<String> include) {
    query.addAll(Include(include).asQueryParameters);
  }

  /// Sets sorting parameters.
  /// See https://jsonapi.org/format/#fetching-sorting
  void sort(Iterable<String> sort) {
    query.addAll(Sort(sort).asQueryParameters);
  }

  /// Requests sparse fieldsets.
  /// See https://jsonapi.org/format/#fetching-sparse-fieldsets
  void fields(Map<String, Iterable<String>> fields) {
    query.addAll(Fields(fields).asQueryParameters);
  }

  /// Sets pagination parameters.
  /// See https://jsonapi.org/format/#fetching-pagination
  void page(Map<String, String> page) {
    query.addAll(Page(page).asQueryParameters);
  }

  /// Response filtering.
  /// https://jsonapi.org/format/#fetching-filtering
  void filter(Map<String, String> filter) {
    query.addAll(Filter(filter).asQueryParameters);
  }
}
