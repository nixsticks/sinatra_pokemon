require 'rack/session/moneta'
require 'yaml'
require 'bundler'
Bundler.require

require_relative './lib/trainer'
require_relative './lib/pokemon'

module PokemonGame
  class App < Sinatra::Application
    use Rack::Session::Moneta, :store => Moneta.new(:Memory, :expires => true)

    set :pokemon, YAML::load(File.open('./lib/pokedex.yaml'))
    set :starters, ["Bulbasaur", "Squirtle", "Charmander"]

    get '/' do
      session[:trainer] = Trainer.new
      session[:opponents] = []
      session[:opponent] = nil
      @lines = lines('intro.txt')
      @image = "oak"
      haml :oneimage
    end

    get '/starters' do
      @lines = lines('starters.txt')
      @images = settings.starters
      haml :threeimages
    end

    get '/choose_starter' do
      @action = "starter"
      @line = "Choose wisely!"
      @choices = settings.starters
      haml :threebuttons
    end

    post '/starter' do
      session[:trainer].my_pokemon[0] = settings.pokemon.detect {|pokemon| pokemon.name == params["0"]}
      @trainer = session[:trainer]
      @line = "You chose #{@trainer.my_pokemon[0].name}!"
      @image = @trainer.my_pokemon[0].name
      haml :oneimage
    end

    get '/battle' do
      @reload = true
      @lines = lines('battle.txt')

      3.times { session[:opponents] << settings.pokemon.sample }

      @opponents = session[:opponents]
      @images = [@opponents[0].name, @opponents[1].name, @opponents[2].name]

      haml :threeimages
    end

    get '/choose_opponent' do
      @opponents = session[:opponents]
      @action = "opponent"
      @line = "Choose wisely!"
      @choices = [@opponents[0].name, @opponents[1].name, @opponents[2].name]
      haml :threebuttons
    end

    post '/opponent' do
      session[:opponent] = settings.pokemon.detect {|pokemon| pokemon.name == params["0"]}
      @opponent = session[:opponent]
      @line = "You chose #{@opponent.name}, a ferocious #{@opponent.type} Pokemon!"
      @image = @opponent.name
      haml :oneimage
    end

    get '/first_fight' do
      @trainer = session[:trainer]
      @opponent = session[:opponent]
      @line = "PREPARE FOR BATTLE!"
      haml :fight
    end

    helpers do
      def simple_partial(template)
        haml template
      end

      def lines(file)
        File.open("./lib/#{file}") {|file| file.readlines.map {|line| line.chomp}}
      end
    end
  end
end

# http://sprites.pokecheck.org/?gen=1