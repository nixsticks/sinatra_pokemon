require 'yaml'
require 'bundler'
Bundler.require

require_relative './lib/trainer'
require_relative './lib/pokemon'

module PokemonGame
  class App < Sinatra::Application
    set :line, 0
    set :player, "Ash"
    set :pokemon, YAML::load(File.open('./lib/pokedex.yaml'))
    set :trainer, Trainer.new
    set :opponents, []
    set :opponent, nil
    set :starters, ["Bulbasaur", "Squirtle", "Charmander"]

    get '/' do
      @reload = true
      @inner = "intro"
      @image = "oak"
      erb :oneimage
    end

    get '/intro' do
      reloader('intro.txt', 'starters', :inner)
    end

    get '/starters' do
      @reload = true
      @inner = "starters_inner"
      @images = settings.starters
      erb :threeimages
    end

    get '/starters_inner' do
      reloader('starters.txt', 'choose_starter', :inner)
    end

    get '/choose_starter' do
      @action = "starter"
      @choices = settings.starters
      erb :threebuttons
    end

    post '/starter' do
      settings.trainer.my_pokemon[0] = settings.pokemon.detect {|pokemon| pokemon.name == params["0"]}
      @trainer = settings.trainer
      @text = "You chose #{@trainer.my_pokemon[0].name}!"
      @image = @trainer.my_pokemon[0].name
      @redirect = redirect('battle', 4000)
      erb :oneimage
    end

    get '/battle' do
      @reload = true
      @inner = "battle_inner"

      3.times { settings.opponents << settings.pokemon.sample }

      @opponents = settings.opponents
      @images = [@opponents[0].name, @opponents[1].name, @opponents[2].name]

      erb :threeimages
    end

    get '/battle_inner' do
      reloader('battle.txt', 'choose_opponent', :inner)
    end

    get '/choose_opponent' do
      @opponents = settings.opponents
      @action = "opponent"
      @images = [@opponents[0].name, @opponents[1].name, @opponents[2].name]
      erb :threebuttons
    end

    post '/opponent' do
      settings.opponent = settings.pokemon.detect {|pokemon| pokemon.name == params["0"]}
      @opponent = settings.opponent
      @text = "You chose #{@opponent.name}, a ferocious #{@opponent.type} Pokemon!"
      @image = @opponent.name
      erb :oneimage
    end

    get '/first_fight' do
      @trainer = settings.trainer
      @opponent = settings.opponent
      erb :first_fight
    end

    helpers do
      def simple_partial(template)
        erb template
      end

      def get_lines(file)
        lines = File.open("./lib/#{file}") {|file| file.readlines.map {|line| line.chomp}}
      end

      def redirect(url, time)
        "<script>
          setTimeout(\"window.location.href='/#{url}';\", 4000);
        </script>"
      end

      def reloader(text_file, redirect_page, inner_view)
        lines = get_lines(text_file)
        @line = lines[settings.line]

        if settings.line == lines.size
          settings.line = 0
          @redirect = redirect(redirect_page, 0)
        else
          settings.line += 1
          erb inner_view, :layout => false
        end
      end
    end
  end
end

# http://sprites.pokecheck.org/?gen=1