# README

This Rails app has been intentionally designed in a way that there are areas for improvement.

It's your mission to find this places and refactor them.

## Requirements to run this app

* Ruby version: `3.2.0`
* Database: `sqlite3`

## How to setup this app
```sh
bin/setup
```

## Useful commands

* `bin/rails test` - it will run the test suite.

* `bin/rails rubycritic` - it will generate a quality report of this codebase.

## Examples of cURL requests to interact with the API

First, run the application:

```sh
bin/rails s
```

Then, use some of the following commands to interact with the API resources:

### Creating a user
```sh
curl -X POST "http://localhost:3000/users/registrations" \
  -H "Content-Type: application/json" \
  -d '{"user":{"name": "Serradura", "email": "serradura@example.com", "password": "123456", "password_confirmation": "123456"}}'
```

### Creating a to-do
```sh
curl -X POST "http://localhost:3000/todos" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SOME-USER-TOKEN" \
  -d '{"todo":{"title": "Buy coffee"}}'
```

### Viewing a to-do
```sh
curl -X GET "http://localhost:3000/todos/1" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SOME-USER-TOKEN"
```

### Listing to-dos
```sh
curl -X GET "http://localhost:3000/todos" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SOME-USER-TOKEN"
```

This resource accepts the status query string to filter the user's to-dos. e.g.

```sh
curl -X GET "http://localhost:3000/todos?status=completed" -H "Content-Type: application/json" -H "Authorization: Bearer SOME-USER-TOKEN"
```

The available statuses to filter are: `overdue`, `completed`, `uncompleted`.

### Updating a to-do
```sh
curl -X PUT "http://localhost:3000/todos/1" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SOME-USER-TOKEN" \
  -d '{"todo":{"title": "Buy milk"}}'
```

### Complete a to-do (it's status will be completed)
```sh
curl -X PUT "http://localhost:3000/todos/1/complete" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SOME-USER-TOKEN"
```

### Uncomplete a to-do (it's status will be uncompleted)
```sh
curl -X PUT "http://localhost:3000/todos/1/uncomplete" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SOME-USER-TOKEN"
```

### Deleting a to-do
```sh
curl -X DELETE "http://localhost:3000/todos/1" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SOME-USER-TOKEN"
```
