class TodosController < ApplicationController
  before_action :authenticate_user

  before_action :set_todo, only: %i[destroy update complete activate]

  rescue_from ActiveRecord::RecordNotFound do
    render_json(404, todo: { id: 'not found' })
  end

  def index
    todos =
      case params[:status]&.strip&.downcase
      when 'active' then Todo.active
      when 'overdue' then Todo.overdue
      when 'completed' then Todo.completed
      else Todo.all
      end

    json = todos.where(user_id: current_user.id).map { |todo| todo_as_json(todo) }

    render_json(200, todos: json)
  end

  def create
    todo = current_user.todos.create(todo_params)

    if todo.valid?
      render_json(201, todo: todo_as_json(todo))
    else
      render_json(422, todo: todo.errors.as_json)
    end
  end

  def destroy
    @todo.destroy

    render_json(200, todo: todo_as_json(@todo))
  end

  def update
    @todo.update(todo_params)

    if @todo.valid?
      render_json(200, todo: todo_as_json(@todo))
    else
      render_json(422, todo: @todo.errors.as_json)
    end
  end

  def complete
    @todo.complete!

    render_json(200, todo: todo_as_json(@todo))
  end

  def activate
    @todo.activate!

    render_json(200, todo: todo_as_json(@todo))
  end

  private

    def todo_params
      params.require(:todo).permit(:title, :due_at)
    end

    def todo_as_json(todo)
      todo.as_json(except: [:user_id], methods: :status)
    end

    def set_todo
      @todo = current_user.todos.find(params[:id])
    end
end
