# frozen_string_literal: true

class TodosController < ApplicationController
  before_action :authenticate_user

  before_action :set_todos
  before_action :set_todo, except: [:index, :create]

  rescue_from ActiveRecord::RecordNotFound do
    render_json(404, todo: { id: 'not found' })
  end

  def index
    todos = @todos.filter_by_status(params).order_by(params).map(&:serialize_as_json)

    render_json(200, todos:)
  end

  def create
    todo = @todos.create(todo_params.except(:completed))

    if todo.valid?
      render_json(201, todo: todo.serialize_as_json)
    else
      render_json(422, todo: todo.errors.as_json)
    end
  end

  def show
    render_json(200, todo: @todo.serialize_as_json)
  end

  def destroy
    @todo.destroy

    render_json(200, todo: @todo.serialize_as_json)
  end

  def update
    @todo.update(todo_params)

    if @todo.valid?
      render_json(200, todo: @todo.serialize_as_json)
    else
      render_json(422, todo: @todo.errors.as_json)
    end
  end

  def complete
    @todo.complete!

    render_json(200, todo: @todo.serialize_as_json)
  end

  def incomplete
    @todo.incomplete!

    render_json(200, todo: @todo.serialize_as_json)
  end

  private

    def set_todos
      @todos = current_user.todos
    end

    def set_todo
      @todo = @todos.find(params[:id])
    end

    def todo_params
      params.require(:todo).permit(:title, :due_at, :completed)
    end
end
