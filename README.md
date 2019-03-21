# Implementation of [{json:api} v1.0](http://jsonapi.org) in Dart
[{json:api} v1.0](http://jsonapi.org) is a specification for building APIs in JSON. This library implements 
a Client (VM, Flutter, Web), and a Server (VM only).


## Supported features
- Fetching single resources and resource collections
- Collection pagination
- Fetching relationships and related resources and collections
- Fetching single resources
- Creating resources
- Deleting resources
- Updating resource's attributes
- Updating resource's relationships
- Updating relationships
- Compound documents
- Related collection pagination
- Asynchronous processing 

## Usage
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