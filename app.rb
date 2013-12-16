require 'bundler'
Bundler.require

module Pokemon
  class App < Sinatra::Application
    get '/' do
      erb :index
    end
  end
end