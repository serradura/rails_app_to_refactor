# README <!-- omit in toc -->

This Rails app has been intentionally designed in a way that there are areas for improvement.

It's your mission to find this places and refactor them.

## Table of Contents
- [Table of Contents](#table-of-contents)
- [Requirements to run this app](#requirements-to-run-this-app)
- [How to setup this app](#how-to-setup-this-app)
- [Useful commands](#useful-commands)
- [Examples of cURL requests to interact with the API](#examples-of-curl-requests-to-interact-with-the-api)
  - [Add a new User](#add-a-new-user)
  - [Delete a User](#delete-a-user)
  - [Add a new To-Do](#add-a-new-to-do)
  - [Display a To-Do (Show a single item from the To-Do List)](#display-a-to-do-show-a-single-item-from-the-to-do-list)
  - [Display the To-Do List (show all items in the To-Do list)](#display-the-to-do-list-show-all-items-in-the-to-do-list)
  - [Edit a To-Do (modify the content of the item)](#edit-a-to-do-modify-the-content-of-the-item)
  - [Mark a To-Do as complete (its status will change to 'completed')](#mark-a-to-do-as-complete-its-status-will-change-to-completed)
  - [Mark a To-Do as incomplete (its status will change to 'incomplete')](#mark-a-to-do-as-incomplete-its-status-will-change-to-incomplete)
  - [Remove a To-Do (the item will be permanently deleted from the list)](#remove-a-to-do-the-item-will-be-permanently-deleted-from-the-list)

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

### Add a new User

```sh
curl -X POST "http://localhost:3000/users" \
  -H "Content-Type: application/json" \
  -d '{"user":{"name": "Serradura", "email": "serradura@example.com", "password": "123456", "password_confirmation": "123456"}}'
```

### Delete a User

```sh
curl -X DELETE "http://localhost:3000/user" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SOME-USER-TOKEN"
```

### Add a new To-Do

```sh
curl -X POST "http://localhost:3000/todos" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SOME-USER-TOKEN" \
  -d '{"todo":{"title": "Buy coffee"}}'
```

### Display a To-Do (Show a single item from the To-Do List)

```sh
curl -X GET "http://localhost:3000/todos/1" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SOME-USER-TOKEN"
```

### Display the To-Do List (show all items in the To-Do list)

```sh
curl -X GET "http://localhost:3000/todos" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SOME-USER-TOKEN"
```

This resource accepts the following query strings:
- status (e.g, 'completed')
- sort_by (e.g, 'updated_at')
- order (e.g, 'asc')

PS: Desc is the default order.

```sh
curl -X GET "http://localhost:3000/todos?status=completed" -H "Content-Type: application/json" -H "Authorization: Bearer SOME-USER-TOKEN"
```

The available statuses to filter are: `overdue`, `completed`, `incomplete`.

### Edit a To-Do (modify the content of the item)

```sh
curl -X PUT "http://localhost:3000/todos/1" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SOME-USER-TOKEN" \
  -d '{"todo":{"title": "Buy milk"}}'
```

### Mark a To-Do as complete (its status will change to 'completed')

```sh
curl -X PUT "http://localhost:3000/todos/1/complete" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SOME-USER-TOKEN"
```

### Mark a To-Do as incomplete (its status will change to 'incomplete')

```sh
curl -X PUT "http://localhost:3000/todos/1/incomplete" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SOME-USER-TOKEN"
```

### Remove a To-Do (the item will be permanently deleted from the list)

```sh
curl -X DELETE "http://localhost:3000/todos/1" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SOME-USER-TOKEN"
```
