module Overdoable
    extend ActiveSupport::Concern

    included do
        scope :overdue, -> { incomplete.where('due_at <= ?', Time.current) }        
    end

    def overdue?
        return false if !due_at || completed_at
    
        due_at <= Time.current
    end
end