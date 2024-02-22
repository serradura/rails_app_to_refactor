class TodoOrderQuery < BaseOrderQuery
    # Available columns to order by to prevent SQL injection
    ALLOWED_SORT_COLUMNS = ['due_at', 'created_at', 'updated_at', 'title', 'completed_at', 'todo_list_id'].freeze
end