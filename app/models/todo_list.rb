# frozen_string_literal: true

class TodoList < ApplicationRecord
  has_many :todos, dependent: :destroy, inverse_of: :todo_list

  belongs_to :user, required: true, inverse_of: :todo_lists

  scope :default, -> { where(default: true) }
  scope :non_default, -> { where(default: false) }

  validates :title, presence: true
  validates :default, inclusion: { in: [true, false] }
  validates :default, uniqueness: { scope: :user_id, message: 'already exists' }, if: :default?

  def serialize_as_json
    as_json(except: [:user_id])
  end
end
