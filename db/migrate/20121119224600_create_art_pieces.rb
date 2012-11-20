class CreateArtPieces < ActiveRecord::Migration

  def change
    create_table :art_pieces do |t|
      t.string    :slug
      t.integer   :format,          :default => 0
      t.string    :url
      t.string    :title
      t.string    :artist
      t.integer   :year,            :length => 4
      t.integer   :width,           :length => 5
      t.integer   :height,          :length => 5
      t.integer   :gallery,         :default => 0
      t.integer   :frame,           :default => 0
      t.integer   :audience,        :default => 0
      t.boolean   :active,          :default => true
      t.datetime  :created_at
      t.datetime  :updated_at
    end
  end

end
