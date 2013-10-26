require "rubygems"

require "bundler"
Bundler.setup

require "sinatra"
require "net/http"


configure do
  APP_ENV = Sinatra::Application.environment.to_s
  APP_ROOT = File.expand_path(File.dirname(__FILE__))
  BIN_ROOT = File.expand_path(File.dirname(__FILE__) +"/bin")
  SKIP_AUTHLOGIC = false

  require "./config.rb"
  %w{haml sinatra/content_for sinatra/respond_to sinatra/r18n sinatra/flash}.each{|r| require r}

  # REQUIRE DATABASE MODELS
  Dir.glob("#{APP_ROOT}/models/*.rb").each{|r| require r}

  files = []
  files += Dir.glob("#{APP_ROOT}/lib/*.rb")
  files.each{|r| require r}

  Sinatra::Application.register Sinatra::RespondTo

  # Ugly override!
  module Sinatra
    module RespondTo
      module Helpers
        def format(val=nil)
          unless val.nil?
            mime_type = ::Sinatra::Base.mime_type(val)
            @_format = val.to_sym
            if mime_type.nil?
              request.path_info << ".#{val}"
              mime_type = 'text/html'
              @_format = 'html'
            end
            response['Content-Type'] ? response['Content-Type'].sub!(/^[^;]+/, mime_type) : content_type(@_format)
          end
          @_format
        end
      end
    end
  end


  FLASH_TYPES = [:warning, :notice, :success, :error]
  use Rack::Session::Cookie, key: 'fartse_rack_key', secret: configatron.cookie_secret, path: '/', expire_after: 21600
  set :sessions => true

  # Allow iframe embedding
  set :protection, except: :frame_options

  # --- I18N -------------------------------
  APP_LOCALES = {
    en: 'English',
  }

  Sinatra::Application.register Sinatra::R18n
  set :default_locale, 'en'
  set :translations,   './i18n'

end

before do
  set_current_user_locale
  set_template_defaults
end