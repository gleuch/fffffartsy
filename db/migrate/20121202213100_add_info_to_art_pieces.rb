class AddInfoToArtPieces < ActiveRecord::Migration

  def change
    add_column :art_pieces, :media, :string, :after => :artist
    add_column :art_pieces, :dimensions, :string, :after => :media
    add_column :art_pieces, :scale, :float, :after => :height, :default => 1.0
  end

end
