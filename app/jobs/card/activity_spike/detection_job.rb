class Card::ActivitySpike::DetectionJob < ApplicationJob
  def perform(card)
    card.detect_activity_spikes
  end
end
