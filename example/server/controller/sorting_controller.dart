import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/query.dart';
import 'package:json_api/server.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:uuid/uuid.dart';

class SortingController extends JsonApiControllerBase<shelf.Request> {
  @override
  FutureOr<JsonApiResponse> fetchCollection(
      shelf.Request request, String type) {
    final sort = Sort.fromUri(request.requestedUri);
    final namesSorted = [...names];
    sort.toList().reversed.forEach((field) {
      namesSorted.sort((a, b) {
        final attrA = a.attributes[field.name].toString();
        final attrB = b.attributes[field.name].toString();
        if (attrA == attrB) return 0;
        return attrA.compareTo(attrB) * field.comparisonFactor;
      });
    });
    return JsonApiResponse.collection(namesSorted);
  }
}

final firstNames = const ['Emma', 'Liam', 'Olivia', 'Noah'];
final lastNames = const ['Smith', 'Johnson', 'Williams', 'Brown'];
final names = firstNames
    .map((first) => lastNames.map((last) => Resource('names', Uuid().v4(),
        attributes: {'firstName': first, 'lastName': last})))
    .expand((_) => _);
