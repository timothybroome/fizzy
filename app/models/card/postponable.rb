module Card::Postponable
  extend ActiveSupport::Concern

  included do
    has_one :not_now, dependent: :destroy, class_name: "Card::NotNow"

    scope :postponed, -> { open.published.joins(:not_now) }
    scope :active, -> { open.published.where.missing(:not_now) }
  end

  def postponed?
    open? && published? && not_now.present?
  end

  def active?
    open? && published? && !postponed?
  end

  def postpone
    transaction do
      send_back_to_triage
      reopen
      activity_spike&.destroy
      create_not_now! unless postponed?
    end
  end

  def resume
    transaction do
      reopen
      activity_spike&.destroy
      not_now&.destroy
    end
  end
end
