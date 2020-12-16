# frozen_string_literal: true

class Todo < ApplicationRecord
  belongs_to :user

  scope :overdue, -> { uncompleted.where('due_at <= ?', Time.current) }
  scope :completed, -> { where.not(completed_at: nil) }
  scope :uncompleted, -> { where(completed_at: nil) }

  validates :title, presence: true
  validates :due_at, presence: true, allow_nil: true
  validates :completed_at, presence: true, allow_nil: true

  def overdue?
    return false if !due_at || completed_at

    due_at <= Time.current
  end

  def uncompleted?
    completed_at.nil?
  end

  def completed?
    !uncompleted?
  end

  def status
    return 'completed' if completed?
    return 'overdue' if overdue?

    'uncompleted'
  end

  def complete
    self.completed_at = Time.current unless completed?
  end

  def complete!
    complete

    self.save if completed_at_changed?
  end

  def uncomplete
    self.completed_at = nil unless uncompleted?
  end

  def uncomplete!
    uncomplete

    self.save if completed_at_changed?
  end

  def serialize_as_json
    as_json(except: [:user_id], methods: :status)
  end
end
