/// The JSON:API Server.
/// **WARNING!**
/// **The server is still under development! Not for production!**
/// **The API is not stable!**
library server;

export 'package:json_api/query.dart';
export 'package:json_api/src/pagination/fixed_size_page.dart';
export 'package:json_api/src/pagination/pagination_strategy.dart';
export 'package:json_api/src/server/controller.dart';
export 'package:json_api/src/server/json_api_server.dart';
export 'package:json_api/src/server/response/accepted_response.dart';
export 'package:json_api/src/server/response/collection_response.dart';
export 'package:json_api/src/server/response/error_response.dart';
export 'package:json_api/src/server/response/meta_response.dart';
export 'package:json_api/src/server/response/no_content_response.dart';
export 'package:json_api/src/server/response/related_collection_response.dart';
export 'package:json_api/src/server/response/related_resource_response.dart';
export 'package:json_api/src/server/response/resource_created_response.dart';
export 'package:json_api/src/server/response/resource_response.dart';
export 'package:json_api/src/server/response/resource_updated_response.dart';
export 'package:json_api/src/server/response/response.dart';
export 'package:json_api/src/server/response/see_other_response.dart';
export 'package:json_api/src/server/response/to_many_response.dart';
export 'package:json_api/src/server/response/to_one_response.dart';
export 'package:json_api/url_design.dart';
