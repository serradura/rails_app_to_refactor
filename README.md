# README <!-- omit in toc -->

This Rails app has been intentionally designed in a way that there are areas for improvement.

It's your mission to find this places and refactor them.

## Requirements to run the app

* Ruby version: `3.2.0`

* Database: `sqlite3`

## How to setup this app

```sh
bin/setup
```

## Table of Contents

- [Requirements to run the app](#requirements-to-run-the-app)
- [How to setup this app](#how-to-setup-this-app)
- [Table of Contents](#table-of-contents)
- [Useful commands](#useful-commands)
- [Examples of cURL requests to interact with the API](#examples-of-curl-requests-to-interact-with-the-api)
  - [Users](#users)
    - [Add new user](#add-new-user)
    - [Display user](#display-user)
    - [Delete user](#delete-user)
  - [To-Do Lists](#to-do-lists)
    - [Add new to-do list](#add-new-to-do-list)
    - [Display to-do list](#display-to-do-list)
    - [Display all to-do lists](#display-all-to-do-lists)
    - [Edit to-do list](#edit-to-do-list)
    - [Remove to-do list](#remove-to-do-list)
  - [To-Dos](#to-dos)
    - [Add new to-do](#add-new-to-do)
      - [Default list](#default-list)
      - [In a list](#in-a-list)
    - [Display to-do](#display-to-do)
      - [Default list](#default-list-1)
      - [From a list](#from-a-list)
    - [Display all to-dos](#display-all-to-dos)
      - [From a list](#from-a-list-1)
    - [Edit to-do](#edit-to-do)
      - [In a list](#in-a-list-1)
    - [Mark to-do as completed](#mark-to-do-as-completed)
      - [In a list](#in-a-list-2)
    - [Mark to-do as incomplete](#mark-to-do-as-incomplete)
      - [In a list](#in-a-list-3)
    - [Remove to-do](#remove-to-do)
      - [From a list](#from-a-list-2)

## Useful commands

* `bin/rails test` - it will run the test suite.

* `bin/rails rubycritic` - it will generate a quality report of this codebase.

## Examples of cURL requests to interact with the API

First, run the application:

```sh
bin/rails s
```

Then, use some of the following commands to interact with the API resources:

### Users

#### Add new user

```sh
curl -X POST "http://localhost:3000/users" \
  -H "Content-Type: application/json" \
  -d '{"user":{"name": "Serradura", "email": "serradura@example.com", "password": "123456", "password_confirmation": "123456"}}'
```

#### Display user

```sh
curl -X GET "http://localhost:3000/user" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SOME-USER-TOKEN"
```

#### Delete user

```sh
curl -X DELETE "http://localhost:3000/user" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SOME-USER-TOKEN"
```

### To-Do Lists

#### Add new to-do list

```sh
curl -X POST "http://localhost:3000/todos_lists" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SOME-USER-TOKEN" \
  -d '{"todo":{"title": "Things to learn"}}'
```

#### Display to-do list

```sh
curl -X GET "http://localhost:3000/todos_lists/1" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SOME-USER-TOKEN"
```

#### Display all to-do lists

```sh
curl -X GET "http://localhost:3000/todo_lists" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SOME-USER-TOKEN"
```

This resource accepts the following query strings:
- sort_by (e.g, 'updated_at')
- order (e.g, 'asc')

PS: Desc is the default order.

**Example:**

```sh
curl -X GET "http://localhost:3000/todo_lists?sort_by=title" -H "Content-Type: application/json" -H "Authorization: Bearer SOME-USER-TOKEN"
```

#### Edit to-do list

```sh
curl -X PUT "http://localhost:3000/todo_lists/1" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SOME-USER-TOKEN" \
  -d '{"todo":{"title": "Things to learn"}}'
```

#### Remove to-do list

```sh
curl -X DELETE "http://localhost:3000/todo_lists/1" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SOME-USER-TOKEN"
```

### To-Dos

#### Add new to-do

##### Default list

```sh
curl -X POST "http://localhost:3000/todos" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SOME-USER-TOKEN" \
  -d '{"todo":{"title": "Buy coffee"}}'
```

##### In a list

```sh
curl -X POST "http://localhost:3000/todo_lists/1/todos" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SOME-USER-TOKEN" \
  -d '{"todo":{"title": "Buy coffee"}}'
```

#### Display to-do

##### Default list

```sh
curl -X GET "http://localhost:3000/todos/1" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SOME-USER-TOKEN"
```

##### From a list

```sh
curl -X GET "http://localhost:3000/todo_lists/1/todos/1" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SOME-USER-TOKEN"
```

#### Display all to-dos

This resource accepts the following query strings:
- status (e.g, 'completed')
- sort_by (e.g, 'updated_at')
- order (e.g, 'asc')

PS: Desc is the default order.

**Example:**

```sh
curl -X GET "http://localhost:3000/todos?status=&sort_by=&order="
  -H "Content-Type: application/json"
  -H "Authorization: Bearer SOME-USER-TOKEN"
```

The available statuses to filter are: `overdue`, `completed`, `incomplete`.

##### From a list

```sh
curl -X GET "http://localhost:3000/todo_lists/1/todos/1?status=&sort_by=&order=" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SOME-USER-TOKEN"
```

#### Edit to-do

Modify the content of the item.

```sh
curl -X PUT "http://localhost:3000/todos/1" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SOME-USER-TOKEN" \
  -d '{"todo":{"title": "Buy milk"}}'
```

**Todo params:**
* title: `string` `required`.
* completed: `boolean` `optional`.

##### In a list

```sh
curl -X PUT "http://localhost:3000/todo_lists/1/todos/1" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SOME-USER-TOKEN" \
  -d '{"todo":{"title": "Buy milk"}}'
```

#### Mark to-do as completed

Change the status to 'completed'.

```sh
curl -X PUT "http://localhost:3000/todos/1/complete" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SOME-USER-TOKEN"
```

##### In a list

```sh
curl -X PUT "http://localhost:3000/todo_lists/1/todos/1/complete" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SOME-USER-TOKEN"
```

#### Mark to-do as incomplete

Change the status to 'incomplete'.

```sh
curl -X PUT "http://localhost:3000/todos/1/incomplete" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SOME-USER-TOKEN"
```

##### In a list

```sh
curl -X PUT "http://localhost:3000/todo_lists/1/todos/1/incomplete" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SOME-USER-TOKEN"
```

#### Remove to-do

The item will be permanently deleted from the list

```sh
curl -X DELETE "http://localhost:3000/todos/1" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SOME-USER-TOKEN"
```

##### From a list

```sh
curl -X DELETE "http://localhost:3000/todo_lists/1/todos/1" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SOME-USER-TOKEN"
```
