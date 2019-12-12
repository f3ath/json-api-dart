/// The URL Design specifies the structure of the URLs used for specific targets.
/// The JSON:API standard describes 4 possible request targets:
/// - Collections (parameterized by the resource type)
/// - Individual resources (parameterized by the resource type and id)
/// - Related resources and collections (parameterized by the resource type, resource id and the relation name)
/// - Relationships (parameterized by the resource type, resource id and the relation name)
///
/// The [UrlFactory] makes those 4 kinds of URLs by the given parameters.
/// The [TargetMatcher] does the opposite, it determines the target of the given
/// URL (if possible). Together they form the UrlDesign.
///
/// This package provides one built-in implementation of UrlDesign which is
/// called [PathBasedUrlDesign] which implements the
/// [Recommended URL Design] allowing you to specify the a common prefix
/// for all your JSON:API endpoints.
///
/// [Recommended URL Design]: https://jsonapi.org/recommendations/#urls
library url_design;

export 'package:json_api/src/url_design/path_based_url_design.dart';
export 'package:json_api/src/url_design/url_design.dart';
