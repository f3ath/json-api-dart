import 'package:json_api/src/server/request/include.dart';
import 'package:json_api/src/server/request/page.dart';

class Query {
  final Page page;
  final Include include;

  Query(Map<String, List<String>> parameters)
      : page = Page.decode(parameters),
        include = Include.decode(parameters);
}
