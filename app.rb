require 'bundler'
Bundler.require

module Pokemon
  class App < Sinatra::Application
    set :line, 0

    get '/' do
      erb :index
    end

    get '/intro' do
      @form = false

      lines = File.open('./lib/intro.txt') do |file|
        file.readlines.map {|line| line.chomp}
      end

      @line = lines[settings.line]

      if settings.line == lines.size
        @form = true
      else
        settings.line += 1
      end

      erb :intro, :layout => false
    end

    get '/battle' do
    end
  end
end

# http://sprites.pokecheck.org/?gen=1