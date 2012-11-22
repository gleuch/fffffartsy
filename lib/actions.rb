# Show art piece
def render_piece
  results = Proc.new {
    @art_piece = ArtPiece.find(params[:id]) rescue nil
    raise ActiveRecord::RecordNotFound if @art_piece.blank?
  }

  respond_to do |format|
    format.html {
      results.call
      haml :'art_pieces/show'
    }
  end
end

get "/pieces/:id/:name" do
  render_piece
end

get "/pieces/:id" do
  render_piece
end


# Get the artwork, save to db, redirect to it
post "/piece/create" do
  results = Proc.new {
    @art_piece = ArtPiece.new(params[:art_piece])
    @art_piece.save
  }

  respond_to do |format|
    format.html {
      if results.call
        redirect "/pieces/#{@art_piece.id}/#{@art_piece.slug}"
      else
        haml :'art_pieces/new'
      end
    }
  end

end

get "/" do
  default_art_piece
  
  respond_to do |format|
    format.html { haml :'art_pieces/new' }
  end
end