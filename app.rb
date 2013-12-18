require 'yaml'
require 'bundler'
Bundler.require

require_relative './lib/trainer'
require_relative './lib/pokemon'

module PokemonGame
  class App < Sinatra::Application
    set :line, 0
    set :player, "Ash"
    set :starters, ["Bulbasaur", "Squirtle", "Charmander"]

    configure do
      @@pokemon = YAML::load(File.open('./lib/pokedex.yaml'))
      @@trainer = Trainer.new
      @@opponents = []
      @@opponent = nil
    end

    get '/' do
      @reload = true
      @inner = "intro"
      @image = "oak"
      erb :index
    end

    get '/intro' do
      reloader('intro.txt', 'starters', :inner)
    end

    get '/starters' do
      @reload = true
      @inner = "starters_inner"
      @images = settings.starters
      erb :starters
    end

    get '/starters_inner' do
      reloader('starters.txt', 'choose_starter', :inner)
    end

    get '/choose_starter' do
      @choices = settings.starters
      @action = "next"
      erb :choose_starter
    end

    post '/next' do
      @@trainer.my_pokemon[0] = @@pokemon.detect {|pokemon| pokemon.name == params["0"]}
      @trainer = @@trainer
      @image = @trainer.my_pokemon[0].name
      @text = "You chose #{@trainer.my_pokemon[0].name}!"
      erb :next
    end

    get '/team' do
      @reload = true
      @inner = "team_inner"
      erb :team
    end

    get '/team_inner' do
      team = []
      5.times { team << @@pokemon.sample }

      @line = team[settings.line].name

      if @line
        settings.line = 0
        @redirect = redirect('battle')
      else
        settings.line += 1
        erb :inner, :layout => false
      end
      # random sample of pokemon make them appear slowly
    end

    get '/battle' do
      @reload = true
      @inner = "battle_inner"

      3.times { @@opponents << @@pokemon.sample }

      @opponents = @@opponents
      @images = [@opponents[0].name, @opponents[1].name, @opponents[2].name]

      erb :battle
    end

    get '/battle_inner' do
      reloader('battle.txt', 'choose_opponent', :inner)
    end

    get '/choose_opponent' do
      @opponents = @@opponents
      @choices = [@opponents[0].name, @opponents[1].name, @opponents[2].name]
      @action = "opponent"
      erb :choose_opponent
    end

    post '/opponent' do
      @@opponent = @@pokemon.detect {|pokemon| pokemon.name == params["0"]}
      @opponent = @@opponent
      @image = @opponent.name
      @text = "You chose #{@opponent.name}, a ferocious #{@opponent.type} Pokemon!"
      erb :opponent
    end

    get '/first_fight' do
      @trainer = @@trainer
      @opponent = @@opponent
      erb :first_fight
    end

    helpers do
      def simple_partial(template)
        erb template
      end

      def get_lines(file)
        lines = File.open("./lib/#{file}") {|file| file.readlines.map {|line| line.chomp}}
      end

      def redirect(url)
        "<script type='text/javascript'>
         window.location.assign('/#{url}')
        </script>"
      end

      def reloader(text_file, redirect_page, inner_view)
        lines = get_lines(text_file)
        @line = lines[settings.line]

        if settings.line == lines.size
          settings.line = 0
          @redirect = redirect(redirect_page)
        else
          settings.line += 1
          erb inner_view, :layout => false
        end
      end
    end
  end
end

# http://sprites.pokecheck.org/?gen=1