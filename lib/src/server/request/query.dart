import 'package:json_api/src/server/request/page.dart';

class Query {
  final Page page;

  Query(Map<String, List<String>> parameters) : page = Page.decode(parameters);
}
