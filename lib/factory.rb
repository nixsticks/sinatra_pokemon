require_relative 'scraper'
require 'yaml'

module PokemonFactory
  def save_images
    scraper = Scraper.new("http://bulbapedia.bulbagarden.net/wiki/List_of_Pok%C3%A9mon_by_National_Pok%C3%A9dex_number")
    pokemon = scraper.get_urls
    pokemon.each do |url|
      scrape = Scraper.new(url)
      image = scrape.get_image
      image_name = /(\D*).png/.match(image)
      File.open("../public/images/#{image_name}", 'wb'){|f| f.write(open(image).read)}
    end
  end

  def first_stage
    scraper = Scraper.new("http://bulbapedia.bulbagarden.net/wiki/List_of_Pok%C3%A9mon_by_evolution_family")
    pokemon = scraper.first_stage_url

    pokemons = []

    pokemon.each do |url|
      scrape = Scraper.new(url)
      name = scrape.get_name
      type = scrape.get_type
      learnset = scrape.get_learnset
      base_stats = scrape.get_base_stats
      evolution = scrape.get_first_evolution
      new_pokemon = Pokemon.new(name, type, learnset, base_stats)
      new_pokemon.evolution = evolution if evolution
      pokemons << new_pokemon
    end

    File.open("first_stages.yaml", "w") do |file|
      file.puts YAML::dump(pokemons)
    end
  end

  def second_stage
    scraper = Scraper.new("http://bulbapedia.bulbagarden.net/wiki/List_of_Pok%C3%A9mon_by_evolution_family")
    pokemon = scraper.second_stage_url

    pokemons = []

    pokemon.each do |url|
      scrape = Scraper.new(url)
      name = scrape.get_name
      type = scrape.get_type
      learnset = scrape.get_learnset
      base_stats = scrape.get_base_stats
      evolution = scrape.get_second_evolution
      new_pokemon = Pokemon.new(name, type, learnset, base_stats)
      new_pokemon.evolution = evolution if evolution
      pokemons << new_pokemon
    end

    File.open("second_stages.yaml", "w") do |file|
      file.puts YAML::dump(pokemons)
    end
  end

  def third_stage
    scraper = Scraper.new("http://bulbapedia.bulbagarden.net/wiki/List_of_Pok%C3%A9mon_by_evolution_family")
    pokemon = scraper.third_stage_url

    pokemons = []

    pokemon.each do |url|
      scrape = Scraper.new(url)
      name = scrape.get_name
      type = scrape.get_type
      learnset = scrape.get_learnset
      base_stats = scrape.get_base_stats
      new_pokemon = Pokemon.new(name, type, learnset, base_stats)
      pokemons << new_pokemon
    end

    File.open("third_stages.yaml", "w") do |file|
      file.puts YAML::dump(pokemons)
    end
  end

  def dynamic_class
    scraper = Scraper.new("http://bulbapedia.bulbagarden.net/wiki/List_of_Pok%C3%A9mon_by_evolution_family")
    pokemon = scraper.second_stage_url

    pokemons = []

    pokemon.each do |url|
      scrape = Scraper.new(url)
      name = scrape.get_name.gsub(/\W/,"").split.join
      type = scrape.get_type
      learnset = scrape.get_learnset
      base_stats = scrape.get_base_stats
      evolution = scrape.get_second_evolution

      Object.const_set(name, Class.new(Pokemon))
      class_name = eval("#{name}")

      new_pokemon = class_name.new(type, learnset, base_stats)
      new_pokemon.evolution = evolution if evolution
      pokemons << new_pokemon
    end

    File.open("test.yaml", "w") do |file|
      file.puts YAML::dump(pokemons)
    end
  end

  def move_list
    File.open("movelist.yaml", "w") do |file|
      file.puts YAML::dump(Scraper.new("http://bulbapedia.bulbagarden.net/wiki/List_of_moves_that_do_damage").get_moves)
    end
  end
end

include PokemonFactory

move_list