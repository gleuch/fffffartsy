class ArtPiece < ActiveRecord::Base

  GALLERIES = {
    0 => 'wall',
  }

  FRAMES = {
    0 => 'white',
    1 => 'black',
    5 => 'gold',
    2 => 'none',
    3 => 'tv',
    4 => 'transparent',
  }

  FORMATS = {
    0 => 'image',
    1 => 'web_page',
    2 => 'video',
  }

  AUDIENCES = {
    0 => 'none',
    # 1 => 'jayz'
  }

  extend FriendlyId
  friendly_id :nice_url, use: :slugged

  default_scope where(active: true)


  def previous(offset = 0)
    self.class.first(conditions: ['id < ?', self.id], limit: 1, offset: offset, order: "id DESC")
  end

  def next(offset = 0)
    self.class.first(conditions: ['id > ?', self.id], limit: 1, offset: offset, order: "id ASC")
  end


  def format_type; ArtPiece::FORMATS[ self.format ]; end
  def gallery_type; ArtPiece::GALLERIES[ self.gallery ]; end
  def frame_type; ArtPiece::FRAMES[ self.frame ]; end
  def audience_type; ArtPiece::AUDIENCES[ self.audience ]; end

  def default=(v); @_default = v; end
  def default; !!@_default; end

  def nice_url; url.gsub(/(http(s)?)(\:\/\/)(www\.)?/i, ''); end

  def piece_url; "/pieces/#{self.id}/#{self.slug}"; end


protected


end