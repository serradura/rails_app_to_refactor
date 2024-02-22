class TodoOrderQuery
    # Available columns to order by to prevent SQL injection
    ALLOWED_SORT_COLUMNS = ['due_at', 'created_at', 'updated_at', 'title', 'completed_at', 'todo_list_id'].freeze
    DEFAULT_SORT_COLUMN = 'id'.freeze
    DEFAULT_SORT_ORDER = :desc.freeze
  
    def initialize(relation, params = {})
      @relation = relation
      @params = params
    end
  
    def call
      column = sort_column
      order = sort_order
  
      @relation.order(column => order)
    end
  
    private
  
    def sort_column
      column = @params[:sort_by]&.strip&.downcase
      ALLOWED_SORT_COLUMNS.include?(column) ? column : DEFAULT_SORT_COLUMN
    end
  
    def sort_order
      @params[:order]&.strip&.downcase == 'asc' ? :asc : DEFAULT_SORT_ORDER
    end
  end
  