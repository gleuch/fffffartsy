require "bundler/setup"

require './config.rb'
require 'sinatra/activerecord/rake'

# Require models
Dir.glob("#{APP_ROOT}/models/*.rb").reject{|r| r.match(/user_session/i)}.each{|r| require r}

namespace :db do
  desc 'Rolls the schema back to the previous version. Specify the number of steps with STEP=n'
  task :rollback do
    steps = ENV['STEP'] ? ENV['STEP'].to_i : 1
    ActiveRecord::Migrator.rollback('db/migrate', steps)
  end
end