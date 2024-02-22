# frozen_string_literal: true

class TodoListsController < ApplicationController
  include TodoListable
  before_action :authenticate_user

  before_action :set_todo_lists
  before_action :set_todo_list, except: [:index, :create]

  rescue_from ActiveRecord::RecordNotFound do |not_found|
    render_json(:not_found, todo_list: { id: not_found.id, message: 'not found' })
  end

  def index
    todo_lists = @todo_lists.order_by(params).map(&:serialize_as_json)

    render_json(:ok, todo_lists: todo_lists)
  end

  def create
    todo_list = @todo_lists.create(todo_list_params)

    if todo_list.valid?
      render_json(:created, todo_list: todo_list.serialize_as_json)
    else
      render_json(:unprocessable_entity, todo_list: todo_list.errors.as_json)
    end
  end

  def show
    render_json(:ok, todo_list: @todo_list.serialize_as_json)
  end

  def destroy
    @todo_list.destroy

    render_json(:ok, todo_list: @todo_list.serialize_as_json)
  end

  def update
    @todo_list.update(todo_list_params)

    if @todo_list.valid?
      render_json(:ok, todo_list: @todo_list.serialize_as_json)
    else
      render_json(:unprocessable_entity, todo_list: @todo_list.errors.as_json)
    end
  end

  private

    def todo_lists_only_non_default? = action_name.in?(['update', 'destroy'])

    def set_todo_list
      @todo_list = @todo_lists.find(params[:id])
    end

    def todo_list_params
      params.require(:todo_list).permit(:title)
    end
end
