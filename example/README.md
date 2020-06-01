# Client-server interaction example
Run the server:
```
$ dart example/server.dart 
Listening on http://localhost:8080

```
This will start a simple JSON:API server at localhost:8080. It supports 2 resource types:
- [writers](http://localhost:8080/writers)
- [books](http://localhost:8080/books)

Try opening these links in your browser, you should see empty collections.

While the server is running, try the client script:
```
$ dart example/client.dart 
POST http://localhost:8080/writers
204
POST http://localhost:8080/books
204
GET http://localhost:8080/books/2?include=authors
200
Book: Resource(books:2 {title: Refactoring})
Author: Resource(writers:1 {name: Martin Fowler})
```
This will create resources in those collections. Try the the following links:

- [writer](http://localhost:8080/writers/1)
- [book](http://localhost:8080/books/2)
- [book and its author](http://localhost:8080/books/2?include=authors)