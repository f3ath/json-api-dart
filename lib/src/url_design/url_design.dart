import 'package:json_api/src/url_design/target_matcher.dart';
import 'package:json_api/src/url_design/url_builder.dart';

/// url_design (URL Design) describes how the endpoints are organized.
abstract class UrlDesign implements TargetMatcher, UrlBuilder {}
