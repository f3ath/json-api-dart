import 'package:json_api/http.dart';
import 'package:json_api/src/client/request/internal/simple_request.dart';
import 'package:json_api/src/client/response/collection_response.dart';
import 'package:json_api/routing.dart';

class FetchRelatedCollection extends SimpleRequest<CollectionResponse> {
  FetchRelatedCollection(String type, String id, String relationship)
      : this.build(RelatedTarget(type, id, relationship));

  FetchRelatedCollection.build(this.target) : super('get');

  @override
  final RelatedTarget target;

  @override
  CollectionResponse response(HttpResponse response) =>
      CollectionResponse.decode(response);
}
