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
    @art_piece = ArtPiece.new(
      :width => 500, :height => 375,
      :url => 'http://fffff.at/files/2011/08/digital-purchase-takedown-notice-500x375.png?e83a2c',
      :format => 0, :frame => 0
    )
    @art_piece.default = true
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
    @body_class = []

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