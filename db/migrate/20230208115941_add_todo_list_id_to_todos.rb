class AddTodoListIdToTodos < ActiveRecord::Migration[7.0]
  def change
    remove_reference(:todos, :user)

    add_reference(:todos, :todo_list, null: false, index: true, foreign_key: true)
  end
end
