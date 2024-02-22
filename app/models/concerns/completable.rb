module Completable
    extend ActiveSupport::Concern
  
    included do
      scope :completed, -> { where.not(completed_at: nil) }
      scope :incomplete, -> { where(completed_at: nil) }
    end

    def complete!
      update(completed_at: Time.current) unless completed?
    end

    def incomplete!
      update(completed_at: nil) if completed?
    end

    def incomplete?
      completed_at.nil?
    end
  
    def completed?
      completed_at.present?
    end
end