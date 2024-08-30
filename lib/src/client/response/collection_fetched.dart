import 'package:http_interop/http_interop.dart' as i;
import 'package:json_api/document.dart';
import 'package:json_api/src/client/response.dart';

class CollectionFetched {
  CollectionFetched(this.rawResponse) {
    final document = InboundDocument(rawResponse.document ??
        (throw FormatException('The document must not be empty')));
    collection.addAll(document.dataAsCollection());
    included.addAll(document.included());
    meta.addAll(document.meta());
    links.addAll(document.links());
  }

  // coverage:ignore-start
  /// The raw HTTP response
  @Deprecated('Use rawResponse.httpResponse instead')
  i.Response get httpResponse => rawResponse.httpResponse;
  // coverage:ignore-end

  /// The raw JSON:API response
  final Response rawResponse;

  /// The resource collection fetched from the server
  final collection = <Resource>[];

  /// Included resources
  final included = <Resource>[];

  /// Top-level meta data
  final meta = <String, Object?>{};

  /// Top-level links object
  final links = <String, Link>{};
}
