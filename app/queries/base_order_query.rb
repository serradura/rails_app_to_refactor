class BaseOrderQuery
    # Available columns to order by to prevent SQL injection
    ALLOWED_SORT_COLUMNS = [].freeze
    DEFAULT_SORT_COLUMN = 'id'.freeze
    DEFAULT_SORT_ORDER = :desc.freeze
  
    def initialize(relation, params = {})
      @relation = relation
      @params = params
    end
  
    def call
      @relation.order(sort_column => sort_order)
    end
  
    protected
  
    def sort_column
      column = @params[:sort_by]&.strip&.downcase
      self.class::ALLOWED_SORT_COLUMNS.include?(column) ? column : self.class::DEFAULT_SORT_COLUMN
    end
  
    def sort_order
      @params[:order]&.strip&.downcase == 'asc' ? :asc : self.class::DEFAULT_SORT_ORDER
    end
end
  