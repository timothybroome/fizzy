class Columns::Cards::Drops::ClosuresController < ApplicationController
  include CardScoped

  def create
    @card.close

    render turbo_stream: turbo_stream.replace("closed-cards", partial: "collections/show/closed", locals: { collection: @card.collection })
  end
end
