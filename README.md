# Implementation of [JSON:API v1.0](http://jsonapi.org) in Dart

## Warning! This is a work-in-progress. While at v0, the API is changing rapidly.

### Feature roadmap
The features here are more or less ordered by priority. Feel free to open an issue if you want to add another feature.

#### Client
- [x] Fetching single resources and resource collections
- [ ] Collection pagination
- [x] Fetching relationships and related resources and collections
- [ ] Related collection pagination
- [x] Fetching single resources
- [x] Creating resources
- [x] Deleting resources
- [x] Updating resource's attributes
- [x] Updating resource's relationships
- [x] Updating relationships
- [ ] Compound documents
- [ ] Asynchronous processing 
- [ ] Optional check for `Content-Type` header in incoming responses 

#### Server
- [x] Fetching single resources and resource collections
- [ ] Collection pagination
- [x] Fetching relationships and related resources and collections
- [ ] Related collection pagination
- [x] Fetching single resources
- [x] Creating resources
- [x] Deleting resources
- [x] Updating resource's attributes
- [x] Updating resource's relationships
- [ ] Updating relationships
- [ ] Compound documents
- [ ] Sparse fieldsets 
- [ ] Sorting, filtering
- [ ] Asynchronous processing 
- [ ] Optional check for `Content-Type` header in incoming requests 
- [ ] Support annotations in resource mappers (?) 

#### Document
- [x] Support relationship objects lacking the `data` member
- [ ] Support `meta` members
- [ ] Support `jsonapi` members
- [ ] Compound documents
- [ ] Structure Validation including compound documents
- [ ] Naming Validation
- [ ] JSON:API v1.1 features

### Usage
In the VM:
```dart
import 'package:json_api/client.dart';

final client = JsonApiClient();
```

In a browser:
```dart
import 'package:json_api/client.dart';
import 'package:http/browser_client.dart';

final client = JsonApiClient(factory: () => BrowserClient());
```

For usage examples see the [functional tests](https://github.com/f3ath/json-api-dart/tree/master/test/functional).