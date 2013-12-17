require './lib/trainer'
require './lib/pokemon'
require 'yaml'

class Game
  attr_reader :pokedex, :trainer
  attr_writer :trainer

  def initialize
    File.open("./first_stages.yaml", "r") {|file| @pokedex = YAML::load(file)}
  end

  def run
    puts new_or_load_message
    run_intro unless new_or_load
    starter_pokemon_message
    get_starter_pokemon
    bonus_pokemon
    puts mulligan_message
    mulligan
    puts save_user_message
    save_user?
  end

  def new_or_load_message
    "Load saved user?"
  end

  def new_or_load
    case get_input
    when /^y(es)?$/ 
      File.open("./trainer.yaml", "r") {|file| @trainer = YAML::load(file)}
      return true
    when /^no?$/
      @trainer = Trainer.new
      return false
    else
      puts "Please answer yes or no."
      new_or_load
    end
  end

  def run_intro
    File.open('intro.txt') do |file|
      file.each do |line|
        puts line
        sleep(1)
      end
    end

    trainer.name = get_input.capitalize

    puts "\n#{trainer.name}! Your very own POKéMON legend is about to unfold!"
    sleep(1)
    puts "A world of dreams and adventures with POKéMON awaits!"
    sleep(1)
    puts "Let’s go!"
  end

  def get_input
    gets.chomp.downcase
  end

  def starter_pokemon_message
    puts "\nI will give you one Pokemon to start out your journey with.\n"
    sleep(1)
    puts "Do you want the grass Pokemon, Bulbasaur?"
    sleep(1)
    puts "Do you want the water Pokemon, Squirtle?"
    sleep(1)
    puts "Or do you want the fire Pokemon, Charmander?"
  end

  def get_starter_pokemon
    desired = get_input

    if /bulbasaur|squirtle|charmander/.match(desired)
      trainer.my_pokemon[0] = pokemon_lookup(desired)
    else
      puts "Sorry, you can't have that Pokemon."
      get_starter_pokemon
    end
  end

  def pokemon_lookup(desired)
    pokedex.each do |pokemon|
      return pokemon if pokemon.name.downcase == desired
    end
  end

  def bonus_pokemon
    puts "\nI'll now give you some bonus Pokemon!"
    sleep(2)
    puts "\nHere are your Pokemon!"
    5.times do |i|
      pokemon = pokedex.sample
      puts
      puts "#{pokemon.name} (#{pokemon.type})"
      puts "Moves:"
      pokemon.moves.each {|move| puts move}
      trainer.my_pokemon[i+1] = pokemon
      sleep(1)
    end
  end

  def mulligan_message
    "\nIf you do not like the Pokemon you were given, print 'redo' to get a new set. This will only work once! \nIf you are happy with your set, print c to cancel."
  end

  def mulligan
    case get_input
    when 'redo'
      puts "\nOkay."
      trainer.my_pokemon = {0 => trainer.my_pokemon[0]}
      bonus_pokemon
    when 'c'
      puts "Good!"
    else
      puts "Please type redo or c."
      mulligan
    end

    puts "\nHere are all your Pokemon!"
    trainer.my_pokemon.each_pair {|number, pokemon| puts "#{pokemon.name} (#{pokemon.type})"}
    puts
  end

  def save_user_message
    "Save user?"
  end

  def save_user?
    case get_input
    when /^y(es)?$/
      File.open("trainer.yaml", "w") {|file| file.puts YAML::dump(trainer)}
    when /^no?$/
      exit
    else
      puts "Please say yes or no."
      save_user?
    end
  end
end


Game.new.run