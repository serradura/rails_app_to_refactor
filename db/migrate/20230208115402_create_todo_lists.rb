class CreateTodoLists < ActiveRecord::Migration[7.0]
  def change
    create_table :todo_lists do |t|
      t.string :title
      t.boolean :default, default: false, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
