class Trainer
  attr_accessor :my_pokemon, :name

  def initialize
    @my_pokemon = {}
  end

  def catch(pokemon)
    size = my_pokemon.size
    my_pokemon[size + 1] = pokemon
  end
end