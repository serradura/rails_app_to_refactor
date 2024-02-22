# frozen_string_literal: true

class TodosController < ApplicationController
  include TodoListable
  before_action :authenticate_user

  before_action :set_todo_lists
  before_action :set_todos
  before_action :set_todo, except: [:index, :create]

  rescue_from ActiveRecord::RecordNotFound do |not_found|
    key = not_found.model == 'TodoList' ? :todo_list : :todo

    render_json(:not_found, key => { id: not_found.id, message: 'not found' })
  end

  def index
    filter = TodoFilterQuery.new(@todos, params).call
    todos = TodoOrderQuery.new(filter, params).call.map(&:serialize_as_json)

    render_json(:ok, todos:)
  end

  def create
    todo = @todos.create(todo_params.except(:completed))

    if todo.valid?
      render_todo_json(:created, todo: todo)
    else
      render_json(:unprocessable_entity, todo: todo.errors.as_json)
    end
  end

  def show
    render_todo_json(:ok, todo: @todo)
  end

  def destroy
    @todo.destroy

    render_json(:ok, todo: @todo.serialize_as_json)
  end

  def update
    @todo.update(todo_params)

    if @todo.valid?
      render_todo_json(:ok, todo: @todo)
    else
      render_json(:unprocessable_entity, todo: @todo.errors.as_json)
    end
  end

  def complete
    TodoCompleter.new(@todo).call

    render_todo_json(:ok, todo: @todo)
  end

  def incomplete
    TodoIncompleter.new(@todo).call

    render_todo_json(:ok, todo: @todo)
  end

  private

    def todo_lists_only_non_default? = false

    def set_todos
      @todos =
        if params[:todo_list_id].present?
          @todo_lists.find(params[:todo_list_id]).todos
        else
          default_or_user_todos
        end
    end

    def set_todo
      @todo = @todos.find(params[:id])
    end

    def todo_params
      params.require(:todo).permit(:title, :due_at, :completed)
    end

    def render_todo_json(status, todo: nil, errors: nil)
      render_json(status, todo: todo ? todo.serialize_as_json : { errors: errors })
    end

    def default_or_user_todos
      action_name == 'create' ? @todo_lists.default.first!.todos : current_user.todos
    end
end
