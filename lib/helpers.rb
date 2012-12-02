helpers do

  def dev?; Sinatra::Application.environment.to_s == 'development'; end
  def stage?; Sinatra::Application.environment.to_s == 'staging'; end
  def test?; Sinatra::Application.environment.to_s == 'testing'; end
  def scrape?; Sinatra::Application.environment.to_s == 'scraper'; end
  def prod?; Sinatra::Application.environment.to_s == 'production'; end

  def flashes?;
   !FLASH_TYPES.reject{|v| flash[v].blank?}.blank?
  end

  def show_flashes
   FLASH_TYPES.reject{|v| flash[v].blank?}.map{|v| "<div class=\"flash flash_#{v.to_s}\">#{flash[v]}</div>"}.join('')
  end

  def pluralize(num=0, str='', p_str=nil)
   if num == 1
     str
   else
     p_str || str.pluralize
   end
  end


# --- Art Pieces --------------------------------------------------------------

  def default_art_piece
    pieces = [
      {:width => 500, :height => 375, :format => 0, :frame => 0, :url => 'http://fffff.at/files/2011/08/digital-purchase-takedown-notice-500x375.png?e83a2c'},
      {:width => 300, :height => 300, :format => 0, :frame => 0, :url => 'https://twimg0-a.akamaihd.net/profile_images/1094166180/t.jpg'},
      {:width => 720, :height => 480, :format => 0, :frame => 0, :url => 'http://www.evan-roth.com/photos//data/dlectricity-2012/web/thelegacyliveson-shot2-nlz-720px.gif'},
      {:width => 323, :height => 500, :format => 0, :frame => 0, :url => 'http://fffff.at/files/2012/06/one_of_-323x500.jpg?e83a2c'},
      {:width => 1500, :height => 1000, :format => 0, :frame => 0, :url => 'http://datenform.de/blog/wp-content/uploads/2012/02/OI-bright-DAM-1.jpg'},
      {:width => 600, :height => 450, :format => 0, :frame => 0, :url => 'http://fffff.at/fuckflickr/data/randy/web/cassette.jpg?e83a2c'},
    ]
    r = rand(pieces.length)
    @art_piece = ArtPiece.new(pieces[r])
    @art_piece.default = true
  end

  def set_media_size(p,v,sw=nil,i=0)
    #  HOW-TO CALCULATE CSS TRANSFORMATION RATIO:
    #  ---------------------------------------------------------------------------
    #  1. Determine artwork frame size (e.g. 500x374)
    #  2. Determine artwork actual size (src for iframe -- e.g. 375x281)
    #  3. Get ratio of actual size to frame size (e.g. width: 375/500 = .75)
    #  4. Set transform/zoom to this percentage (e.g. zoom: .75; [...])
    #  5. Set iframe width / height to 100 / ratio (e.g. 100 / .75 = 133.33 = 133%)

    piece_width, piece_height = p.width, p.height
    piece_width ||= 800
    piece_height ||= 600

    orig_screen_width, orig_screen_height = (sw || 375), 281
    screen_width, screen_height = (orig_screen_width * v[:ratio]).to_i, (orig_screen_height * v[:ratio]).to_i
    screen_zoom_ratio = '%0.02f' % ((screen_width / piece_width.to_f))
    screen_zoom_pct = '%0.02f' % (100 / screen_zoom_ratio.to_f)

    # Set default screen dimensions to 16:9 if tv mode
    if p.format_type == 'video'
     screen_height = ((9 * screen_width) / 16.to_f).to_i rescue 211
    elsif !p.height.blank?
      screen_height = (screen_zoom_ratio.to_f * piece_height).to_i rescue 281
    end

    if screen_height <= (300 * v[:ratio]).to_i
      bg_width = (6578 * (v[:bg_ratio] || v[:ratio])).to_i
      bg_pos_y = (475 * (v[:bg_ratio] || v[:ratio])).to_i
      pos_y = (80 * v[:ratio]).to_i

      # puts screen_zoom_pct

      "<style type=\"text/css\", media=\"#{v[:media]}\">
        #{v[:css]}
        #artwork {width: #{screen_width}px; height: #{screen_height}px; top: #{pos_y}px;}
        #artwork iframe {width: #{screen_zoom_pct}%; height: #{screen_zoom_pct}%; zoom: #{screen_zoom_ratio}; transform: scale(#{screen_zoom_ratio}); transform-origin: left top; -moz-transform: scale(#{screen_zoom_ratio}); -moz-transform-origin: left top; -o-transform: scale(#{screen_zoom_ratio}); -o-transform-origin: left top; -webkit-transform: scale3d(#{screen_zoom_ratio},#{screen_zoom_ratio},1); -webkit-transform-origin: left top; -webkit-perspective: #{screen_zoom_pct.to_i};}
        #gallery {background-size: #{bg_width}px auto; background-position: center #{bg_pos_y}px;}
       </style>"
    else
      adjusted_screen_width = (screen_width * (280 / screen_height.to_f)).to_i
      set_media_size(p,v,adjusted_screen_width,1) unless i > 0
    end
  end

  def media_sizes
    {
      :screen_normal => {
        :ratio => 1,
        :media => 'only screen'
      },
      :screen_small => {
        :ratio => 0.8,
        :media => 'only screen and (max-width: 650px)'#', only screen and (max-width: 1300px) and (-webkit-min-device-pixel-ratio: 2)'
      },
      :screen_smaller => {
        :ratio => 0.69,
        :media => 'only screen and (max-width: 550px)'#', only screen and (max-width: 1000px) and (-webkit-min-device-pixel-ratio: 2)'
      },
      :screen_smallest => {
        :ratio => 0.4,
        :media => 'only screen and (max-width: 450px)'#', only screen and (max-width: 900px) and (-webkit-min-device-pixel-ratio: 2)'
      },
      :screen_mobile => {
        :ratio => 0.4,
        :media => 'only screen and (max-device-width: 480px), only screen and (min-device-width: 640px) and (max-device-width: 1136px) and (-webkit-min-device-pixel-ratio: 2)'
      }
    }
  end

# --- Templates ---------------------------------------------------------------

  def set_current_user_locale
    locale = session[:locale]
    locale ||= params[:locale] unless params[:locale].blank?
    locale ||= 'en'
    session[:locale] = locale if APP_LOCALES.keys.include?(locale.to_sym)
  end


  def set_template_defaults
    @meta = {
      :description => t.template.meta.description,
      :robots => "index,follow"
    }
    
    @title = nil
    @body_classes = []

    @add_javascripts = [
      {:src => "/js/jquery-1.8.3.min.js"},
      {:src => "/js/site.js"}
    ]

    @add_stylesheets = [
      {:href => "/css/default.css"},
      {:href => "/css/screen.css", :media => "only screen"},
      {:href => "/css/mobile.css", :media => "only screen"}
    ]

    # flash.now[:info] = t.template.alert.high_traffic
  end

  def page_title
    str = [ t['title_name'] ]
    str.unshift(@title) unless @title.blank?
    str.join(' | ')
  end

  def locale_haml(f,locale=nil)
    locale ||= session[:locale]
    begin
      haml("#{f.to_s}.#{locale}".to_sym)
    rescue
      Audit.warning(:loggable => Sinatra, :message => "Locale HAML: Missing language file: #{f}", :script => f)
      (dev ? "<p><em>Error:</em> Missing language file for #{f}.</p>" : '')
    end
  end



  def error_messages_for(object, header_message=nil, clear_column_name=false)
    u_klass, str = object.class.name.underscore.pluralize.to_sym, ''
    
    # Use model name, if translated, else just humanize it.
    h_klass = t.models[object.class.name.underscore.to_sym].downcase if t.models[object.class.name.underscore.to_sym].translated?
    h_klass ||= object.class.name.underscore.humanize.downcase


    if !object.errors.blank?
      str << "<div class='form_errors'>"

      if !header_message.blank?
        str << "<div class='form_errors_header'>#{header_message}</div>"
      else
        m = (!object.new_record? ? 'update' : 'create').to_sym
        s = t.errors[u_klass].heading[m] if t.errors[u_klass].heading[m].translated? rescue nil
        s ||= t.defaults.error_for.send(m, h_klass)
        str << "<div class='form_errors_header form_errors_for_#{m.to_s}'>#{s}</div>"
      end

      str << "<ul>"
      object.errors.keys.each do |err|
        err = err[1] if clear_column_name == true
        str << "<li>#{t.errors[u_klass][err.to_sym]}</li>"
      end

      str << "</ul>"
      str << "</div>"
    end

    str
  end


  class Array
    def humanize_join(str=',')
      if self.length > 2
        l = self.pop
        "#{self.join(', ')} #{str} #{l}"
      elsif self.length == 2
        "#{self.shift} #{str} #{self.pop}"
      else
        self.to_s rescue ''
      end
    end

    def and_join
      self.humanize_join( R18n.t.defaults.and )
    end

    def or_join
      self.humanize_join( R18n.t.defaults.or )
    end
  end

end