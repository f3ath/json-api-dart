/// # The JSON:API Server
///
/// The server API is not stable. Expect breaking changes.
library server;

export 'package:json_api/src/server/http_handler.dart';
export 'package:json_api/src/server/json_api_controller.dart';
export 'package:json_api/src/server/pagination/fixed_size_page.dart';
export 'package:json_api/src/server/pagination/pagination_strategy.dart';
export 'package:json_api/src/server/response/accepted_response.dart';
export 'package:json_api/src/server/response/collection_response.dart';
export 'package:json_api/src/server/response/error_response.dart';
export 'package:json_api/src/server/response/json_api_response.dart';
export 'package:json_api/src/server/response/meta_response.dart';
export 'package:json_api/src/server/response/no_content_response.dart';
export 'package:json_api/src/server/response/related_collection_response.dart';
export 'package:json_api/src/server/response/related_resource_response.dart';
export 'package:json_api/src/server/response/resource_created_response.dart';
export 'package:json_api/src/server/response/resource_response.dart';
export 'package:json_api/src/server/response/resource_updated_response.dart';
export 'package:json_api/src/server/response/see_other_response.dart';
export 'package:json_api/src/server/response/to_many_response.dart';
export 'package:json_api/src/server/response/to_one_response.dart';
export 'package:json_api/src/server/server_document_factory.dart';
export 'package:json_api/src/server/target.dart';
