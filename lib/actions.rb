# Show art piece
def render_piece
  results = Proc.new {
    @art_piece ||= ArtPiece.find(params[:id]) rescue nil
    raise ActiveRecord::RecordNotFound if @art_piece.blank?
  }

  
  respond_to do |format|
    format.html {
      results.call
      haml :'art_pieces/show'
    }
  end
end

get "/pieces" do
  results = Proc.new {
    @art_pieces = ArtPiece.order('created_at desc').paginate(:page => params[:page] || 1, :per_page => 50)
  }

  respond_to do |format|
    format.html {
      results.call
      haml :'art_pieces/index'
    }
  end
end

# Show random piece
get "/pieces/random" do
  results = Proc.new {
    @art_piece = ArtPiece.order('RAND()').first rescue nil
    raise ActiveRecord::RecordNotFound if @art_piece.blank?
  }

  
  respond_to do |format|
    format.html {
      results.call
      redirect @art_piece.piece_url
    }
  end
end

# Helps prevent weird padding issue with images inside iframes (firefox)
get "/pieces/:id/:format_type" do
  results = Proc.new {
    if params[:id] == 'preview'
      raise ActiveRecord::RecordNotFound unless ['image','video'].include?(params[:format_type])
      raise ActiveRecord::RecordNotFound if params[:url].blank?
    else
      pass unless ['image','video'].include?(params[:format_type])
      @art_piece = ArtPiece.find(params[:id]) rescue nil
      raise ActiveRecord::RecordNotFound if @art_piece.blank?
      raise ActiveRecord::RecordNotFound if @art_piece.format_type != params[:format_type]
    end
  }

  respond_to do |format|
    format.html {
      results.call
      haml "art_pieces/#{params[:format_type]}".to_sym
    }
  end
end

get "/pieces/:id/:slug" do
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
        redirect @art_piece.piece_url
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