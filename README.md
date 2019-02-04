# Implementation of [JSON:API v1.0](http://jsonapi.org) in Dart

**This is a work in progress. The API may change.**

## General architecture

The library consists of three major parts: Document, Server, and Client.

### Document
This is the core part. 
It describes JSON:API Document and its components (e.g. Resource Objects, Identifiers, Relationships, Links), 
validation rules (naming conventions, full linkage), and service discovery (e.g. fetching pages and related resources).

### Client
This is a JSON:API client based on Dart's native HttpClient.

### Server
A JSON:API server. Routes requests, builds responses.