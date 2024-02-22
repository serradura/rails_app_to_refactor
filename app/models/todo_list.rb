# frozen_string_literal: true

class TodoList < ApplicationRecord
  has_many :todos, dependent: :destroy, inverse_of: :todo_list

  belongs_to :user, required: true, inverse_of: :todo_lists

  scope :default, -> { where(default: true) }
  scope :non_default, -> { where(default: false) }

  validates :title, presence: true
  validates :default, inclusion: { in: [true, false] }
  validate :default_uniqueness

  def serialize_as_json
    as_json(except: [:user_id])
  end

  private

    def default_uniqueness
      errors.add(:default, 'already exists') if default? && user.todo_lists.default.exists?
    end
end
