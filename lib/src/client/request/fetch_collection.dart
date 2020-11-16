import 'package:json_api/http.dart';
import 'package:json_api/src/client/request/internal/simple_request.dart';
import 'package:json_api/src/client/response/collection_response.dart';
import 'package:json_api/routing.dart';

class FetchCollection extends SimpleRequest<CollectionResponse> {
  FetchCollection(String type) : this.build(CollectionTarget(type));

  FetchCollection.build(this.target) : super('get');

  @override
  final CollectionTarget target;

  @override
  CollectionResponse response(HttpResponse response) =>
      CollectionResponse.decode(response);
}
