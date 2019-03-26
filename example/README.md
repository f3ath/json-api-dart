# JSON:API examples

## [Cars Server](./cars_server)
This is a simple JSON:API server which is used in the tests. It provides an API to a collection to car companies and models.
You can run it locally to play around.

- In you console run `dart example/cars_server.dart`, this will start the server at port 8080.
- Open http://localhost:8080/companies in the browser.

## [Fetch example](./fetch_collection.dart)
With the server running, call
```
dart example/fetch_collection.dart
```
This will make a `fetchCollection()` call and print the response.