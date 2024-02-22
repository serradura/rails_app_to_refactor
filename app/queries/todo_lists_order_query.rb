class TodoListsOrderQuery < BaseOrderQuery
    # Available columns to order by to prevent SQL injection
    ALLOWED_SORT_COLUMNS = ['created_at', 'updated_at', 'title'].freeze
end
  