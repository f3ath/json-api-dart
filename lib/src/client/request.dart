import 'package:json_api/http.dart';
import 'package:json_api/query.dart';
import 'package:json_api/src/client/client.dart';

/// A generic JSON:API request.
class Request with HttpHeaders {
  /// Creates a new instance if the request with the specified HTTP [method]
  /// and [document].
  Request(this.method, [this.document]);

  /// Creates a GET request.
  Request.get() : this('get');

  /// Creates a POST request.
  Request.post([Object? document]) : this('post', document);

  /// Creates a DELETE request.
  Request.delete([Object? document]) : this('delete', document);

  /// Creates a PATCH request.
  Request.patch([Object? document]) : this('patch', document);

  /// HTTP method
  final String method;

  /// JSON:API document. This object can be of any type as long as it is
  /// encodable by the [PayloadCodec] used in the [Client].
  final Object? document;

  /// Query parameters
  final query = <String, List<String>>{};

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
