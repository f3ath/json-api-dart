import 'package:json_api/src/routing/target_matcher.dart';
import 'package:json_api/src/routing/url_builder.dart';

/// routing (URL Design) describes how the endpoints are organized.
abstract class UrlDesign implements TargetMatcher, UrlBuilder {}
