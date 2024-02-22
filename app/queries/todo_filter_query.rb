class TodoFilterQuery
    def initialize(relation, params = {})
      @relation = relation
      @params = params
    end

    def call
        filter_by_status
    end

    private

    def filter_by_status
        case @params[:status]&.strip&.downcase
        when 'overdue'
          @relation.overdue
        when 'completed'
          @relation.completed
        when 'incomplete'
          @relation.incomplete
        else
          @relation
        end
    end
end