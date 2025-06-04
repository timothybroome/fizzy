module Card::Stallable
  extend ActiveSupport::Concern

  STALLED_AFTER_LAST_SPIKE_PERIOD = 14.days

  included do
    has_one :activity_spike, class_name: "Card::ActivitySpike", dependent: :destroy

    scope :with_activity_spikes, -> { joins(:activity_spike) }
    scope :stalled, -> { with_activity_spikes.where(updated_at: ..STALLED_AFTER_LAST_SPIKE_PERIOD.ago) }

    after_update_commit :detect_activity_spikes_later, if: :saved_change_to_last_active_at?
  end

  def stalled?
    activity_spike && activity_spike.updated_at < STALLED_AFTER_LAST_SPIKE_PERIOD.ago
  end

  def detect_activity_spikes
    Card::ActivitySpike::Detector.new(self).detect
  end

  private
    def detect_activity_spikes_later
      Card::ActivitySpike::DetectionJob.perform_later(self)
    end
end
