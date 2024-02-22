module TodoListable
    protected

    def set_todo_lists
        user_todo_lists = current_user.todo_lists
  
        @todo_lists = todo_lists_only_non_default? ? user_todo_lists.non_default : user_todo_lists
    end
end