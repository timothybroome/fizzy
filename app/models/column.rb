class Column < ApplicationRecord
  include Positioned

  belongs_to :collection, touch: true
  has_many :cards, dependent: :nullify

  before_validation :set_default_color
  after_save_commit    -> { cards.touch_all }, if: -> { saved_change_to_name? || saved_change_to_color? }
  after_destroy_commit -> { collection.cards.touch_all }

  private
    def set_default_color
      self.color ||= Card::DEFAULT_COLOR
    end
end
