class Command::Do < Command
  include Command::Cards

  store_accessor :data, :statues_by_card_id

  def title
    "Move #{cards_description} to Doing"
  end

  def execute
    statues_by_card_id = {}

    transaction do
      cards.find_each do |card|
        statues_by_card_id[card.id] = { closed: card.closed?, doing: card.doing?, considering: card.considering? }
        card.engage
      end

      update! statues_by_card_id: statues_by_card_id
    end
  end

  def undo
    transaction do
      statues_by_card_id.each do |card_id, data|
        if card = user.accessible_cards.find_by_id(card_id)
          card.close if data["closed"]
          card.engage if data["doing"]
          card.reconsider if data["considering"]
        end
      end
    end
  end
end
