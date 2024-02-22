# frozen_string_literal: true

class Todo < ApplicationRecord
  include Completable
  include Overdoable
  
  belongs_to :todo_list, required: true, inverse_of: :todos

  has_one :user, through: :todo_list

  validates :title, presence: true

  def completed=(value)
    case value.to_s
    when 'true' then complete!
    when 'false' then incomplete!
    end
  end

  def status
    return 'completed' if completed?
    return 'overdue' if overdue?

    'incomplete'
  end

  def serialize_as_json
    as_json(except: [:completed], methods: :status)
  end
end
