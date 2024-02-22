# frozen_string_literal: true

class Todo < ApplicationRecord

  belongs_to :todo_list, required: true, inverse_of: :todos

  has_one :user, through: :todo_list

  scope :overdue, -> { incomplete.where('due_at <= ?', Time.current) }
  scope :completed, -> { where.not(completed_at: nil) }
  scope :incomplete, -> { where(completed_at: nil) }

  validates :title, presence: true

  def completed=(value)
    case value.to_s
    when 'true' then complete!
    when 'false' then incomplete!
    end
  end

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

  def complete!
    return if completed?
    update(completed_at: Time.current)
  end

  def incomplete!
    return if incomplete?
    update(completed_at: nil)
  end

  def serialize_as_json
    as_json(except: [:completed], methods: :status)
  end
end
