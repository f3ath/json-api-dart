# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- Sound null-safety support.

### Changed
- Everything. Again. This is another major **BC-breaking** rework. Please refer to 
  the API documentation, examples and tests.

## [4.3.0] - 2020-07-30
### Added
- `meta` parameter for createResourceAt()

### Removed
- Dropped support for Dart 2.6

## [4.2.2] - 2020-06-05
### Fixed
- Client throws NoSuchMethodError on unexpected primary data ([issue](https://github.com/f3ath/json-api-dart/issues/102)).

## [4.2.1] - 2020-06-04
### Fixed
- The server library was not exporting `Controller`.
- `ResourceData.toJson()` was not calling the underlying `ResourceObject.toJson()`.

## [4.2.0] - 2020-06-03
### Added
- Filtering support for collections ([pr](https://github.com/f3ath/json-api-dart/pull/97))

### Changed
- The client will not attempt to decode the body of the HTTP response with error status if the correct Content-Type
  is missing. Before in such cases a `FormatException` would be thrown ([pr](https://github.com/f3ath/json-api-dart/pull/98))

## [4.1.0] - 2020-05-28
### Changed
- `DartHttp` now defaults to utf8 if no encoding is specified in the response.

## [4.0.0] - 2020-02-29
### Changed
- Everything. This is a major **BC-breaking** rework which affected pretty much all areas. Please refer to the documentation.

## [3.2.3] - 2020-08-06
### Fixed
- Call toJson() on resourceObject when serializing ([#84](https://github.com/f3ath/json-api-dart/pull/84))


## [3.2.2] - 2020-01-07
### Fixed
-  Can not decode related resource which is null ([#77](https://github.com/f3ath/json-api-dart/issues/77))

## [3.2.1] - 2020-01-01
### Fixed
-  Incorrect URL in the example in the Client documentation ([#74](https://github.com/f3ath/json-api-dart/issues/74))

## [3.2.0] - 2019-12-30
### Added
- `matchBase` option to `PathBasedUrlDesign`.
- `Resource.toIdentifier()`method.

### Changed
- (Server, BC-breaking) `JsonApiController` made generic.

### Removed
- The package does not depend on `collection` anymore.

## [3.1.0] - 2019-12-19
### Added
- (Server) Routing is exposed via `server` library.

### Changed
- (Server, BC-breaking) `Controller` renamed to `JsonApiController`.
- (Server, BC-breaking) `Response` renamed to `JsonApiResponse`.

### Fixed
- (Server) Response classes had `included` member initialized to `[]` by default. Now the default is `null`.

## [3.0.0] - 2019-12-17
### Added
- Support for custom non-standard links ([#61](https://github.com/f3ath/json-api-dart/issues/61))
- Client supports `jsonapi` key in outgoing requests.
- `Document.contentType` constant.
- `IdentifierObject.fromIdentifier` factory method

### Changed
Most of the changes are **BC-BREAKING**.
- `URLBuilder` was renamed to `UrlFactory`.
- `DocumentBuilder` was split into `ServerDocumentFactory` and `ClientDocumentFactory`. Some methods were renamed.
- Static `decodeJson` methods were renamed to `fromJson`.
- `Identifier.equals` now requires the runtime type to be exactly the same.
- `Link.decodeJsonMap` was renamed to `mapFromJson`.
- The signature of `TargetMatcher`.
- The signature of `Controller`.
- `Server` was renamed to `JsonApiServer`.
- `Pagination` was renamed to `PaginationStrategy`.
 
### Removed
- (Server) `ResourceTarget`, `CollectionTarget`, `RelationshipTarget`  classes.
- `QueryParameters` interface.
- `Router` class.
- `Query` class.

## [2.1.0] - 2019-12-04
### Added
- `onHttpCall` hook to enable raw http request/response logging ([#60](https://github.com/f3ath/json-api-dart/issues/60)).

## [2.0.3] - 2019-09-29
### Fixed
- Documentation links got broken due to pub.dev update.

## [2.0.2] - 2019-08-01
### Fixed
- Meta members have incorrect type ([#54](https://github.com/f3ath/json-api-dart/issues/54)).

## [2.0.1] - 2019-07-12
### Fixed
- Readme example was outdated.

## [2.0.0] - 2019-07-12

### Changed
- This package now consolidates the Client, the Server and the Document in one single library. 
    It does not depend on `json_api_document` and `json_api_server` anymore, please remove these packages 
    from your `pubspec.yaml`.
- The min Dart SDK version bumped to `2.3.0`
- The Client requires an instance of HttpClient to be passed to the constructor explicitly.
- Both the Document and the Server have been refactored with lots of **BREAKING CHANGES**. 
    See the examples and the functional tests for details.
- Meta properties are not defensively copied, but set directly. Meta property behavior is unified across 
    the Document model.

### Removed
- `JsonApiParser` is removed. Use the static `decodeJson` methods in the corresponding classes instead.


## [1.0.1] - 2019-04-05
### Fixed
- Bumped the dependencies versions due to a bug in `json_api_document`.

## [1.0.0] - 2019-03-20
### Changed
- JSON:API Server moved out

## [0.6.0] - 2019-03-25
### Changed
- JSON:API Document moved out
- Renamed `client.removeToOne(...)` to `client.deleteToOne(...)`

## [0.5.0] - 2019-03-21
### Changed
- More BC-breaking changes in the Server

### Fixed
- Location headers were incorrectly generated by Server

### Added
- Related collection pagination
- Async operations support

## [0.4.0] - 2019-03-17
### Changed
- Parsing logic moved out
- Some other BC-breaking changes in the Document
- Huge changes in the Server

### Added
- Compound documents support in Client (Server-side support is still very limited)

### Fixed
- Server was not setting links for resources and relationships

## [0.3.0] - 2019-03-16
### Changed
- Huge BC-breaking refactoring in the Document model which propagated everywhere

### Added
- Resource attributes update
- Resource relationships update

## [0.2.0] - 2019-03-01
### Added
- Improved ResourceController error handling
- Resource creation
- Resource deletion

## [0.1.0] - 2019-02-27
### Added
- Client: fetch resources, collections, related resources and relationships

[Unreleased]: https://github.com/f3ath/json-api-dart/compare/4.3.0..HEAD
[4.3.0]: https://github.com/f3ath/json-api-dart/compare/4.2.2...4.3.0
[4.2.2]: https://github.com/f3ath/json-api-dart/compare/4.2.1...4.2.2
[4.2.1]: https://github.com/f3ath/json-api-dart/compare/4.2.0...4.2.1
[4.2.0]: https://github.com/f3ath/json-api-dart/compare/4.1.0...4.2.0
[4.1.0]: https://github.com/f3ath/json-api-dart/compare/4.0.0...4.1.0
[4.0.0]: https://github.com/f3ath/json-api-dart/compare/3.2.2...4.0.0
[3.2.3]: https://github.com/f3ath/json-api-dart/compare/3.2.2..3.2.3
[3.2.2]: https://github.com/f3ath/json-api-dart/compare/3.2.1..3.2.2
[3.2.1]: https://github.com/f3ath/json-api-dart/compare/3.2.0...3.2.1
[3.2.0]: https://github.com/f3ath/json-api-dart/compare/3.1.0...3.2.0
[3.1.0]: https://github.com/f3ath/json-api-dart/compare/3.0.0...3.1.0
[3.0.0]: https://github.com/f3ath/json-api-dart/compare/2.1.0...3.0.0
[2.1.0]: https://github.com/f3ath/json-api-dart/compare/2.0.3...2.1.0
[2.0.3]: https://github.com/f3ath/json-api-dart/compare/2.0.2...2.0.3
[2.0.2]: https://github.com/f3ath/json-api-dart/compare/2.0.1...2.0.2
[2.0.1]: https://github.com/f3ath/json-api-dart/compare/2.0.0...2.0.1
[2.0.0]: https://github.com/f3ath/json-api-dart/compare/1.0.1...2.0.0
[1.0.1]: https://github.com/f3ath/json-api-dart/compare/1.0.0...1.0.1
[1.0.0]: https://github.com/f3ath/json-api-dart/compare/0.6.0...1.0.0
[0.6.0]: https://github.com/f3ath/json-api-dart/compare/0.5.0...0.6.0
[0.5.0]: https://github.com/f3ath/json-api-dart/compare/0.4.0...0.5.0
[0.4.0]: https://github.com/f3ath/json-api-dart/compare/0.3.0...0.4.0
[0.3.0]: https://github.com/f3ath/json-api-dart/compare/0.2.0...0.3.0
[0.2.0]: https://github.com/f3ath/json-api-dart/compare/0.1.0...0.2.0
[0.1.0]: https://github.com/f3ath/json-api-dart/releases/tag/0.1.0
