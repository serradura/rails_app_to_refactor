# frozen_string_literal: true

class Todo < ApplicationRecord
  belongs_to :user

  scope :overdue, -> { incomplete.where('due_at <= ?', Time.current) }
  scope :completed, -> { where.not(completed_at: nil) }
  scope :incomplete, -> { where(completed_at: nil) }

  validates :title, presence: true
  validates :due_at, presence: true, allow_nil: true
  validates :completed_at, presence: true, allow_nil: true

  def overdue?
    return false if !due_at || completed_at

    due_at <= Time.current
  end

  def incomplete?
    completed_at.nil?
  end

  def completed?
    !incomplete?
  end

  def status
    return 'completed' if completed?
    return 'overdue' if overdue?

    'incomplete'
  end

  def complete
    self.completed_at = Time.current unless completed?
  end

  def complete!
    complete

    self.save if completed_at_changed?
  end

  def incomplete
    self.completed_at = nil unless incomplete?
  end

  def incomplete!
    incomplete

    self.save if completed_at_changed?
  end

  def serialize_as_json
    as_json(except: [:user_id], methods: :status)
  end
end
