require 'nokogiri'
require 'open-uri'

class Scraper
  attr_reader :html

  def initialize(url)
    @html = Nokogiri::HTML(open(url))
  end

  def get_urls
    pokemons = html.xpath('//a[contains(@title, "(Pokémon)")]').map { |link| link['href'] }
    urls = pokemons.map {|url| url = "http://bulbapedia.bulbagarden.net" + url}
  end

  def get_name
    html.search('.firstHeading').text.gsub(" (Pokémon)", "")
  end

  def get_learnset
    moves = html.search('//h3[contains(span, "Learnset")]/following::table//a[contains(@title, "(move)")]/span[following::span[contains(@id, "By_TM.2FHM")]]').map {|move| move.text}
    levels = html.search('//h3[contains(span, "Learnset")]/following::table//tr/td[position()=1]/span[following::span[contains(@id, "By_TM.2FHM")]]').map {|level| level.text}
    learnset = {}
    size = moves.size

    size.times do |i|
      learnset[moves[i]] = levels[i].to_i
    end
    learnset
  end

  def get_base_stats
    stats = html.search('//a[contains(@title, "Stats")]/span').map{|stat| stat.text == "Stat" ? next : stat.text}.compact
    stats.map! {|stat| stat.gsub(".", "_")}
    values = html.search('//h4[contains(span, "Base stats")]/following::tr/th[contains(@style, "30")][following::th[contains(text(), "Total:")]]').map{|number| number.text.chomp}
    base_stats = {}
    size = stats.size

    size.times do |i|
      base_stats[stats[i].downcase] = values[i].to_i
    end

    base_stats
  end

  def get_type
    html.search('//a[contains(@title, "(type)")]/span')[0].text
  end

  def get_image
    html.search("//img[contains(@alt, \"#{get_name}\")]")[0]['src']
  end

  def get_moves
    move_list = {}

    moves = html.search('//td[1]').map {|move| move.text.gsub(/\n|^\s/, "")}
    moves.delete(moves.first)
    moves.delete(moves.last)
    types = html.search('//td[2]').map {|stat| stat.text.gsub(/\n|^\s/, "")}
    categories = html.search('//td[3]').map {|stat| stat.text.gsub(/\n|^\s/, "")}
    powers = html.search('//td[4]').map {|stat| stat.text.gsub(/\s/, "").gsub("—", "special")}
    accuracies = html.search('//td[5]').map {|stat| stat.text.gsub(/[\s\%]/, "").gsub("—", "special")}

    moves.size.times do |i|
      move_list[moves[i]] = {}
      move_list[moves[i]][:type] = types[i]
      move_list[moves[i]][:category] = categories[i]
      move_list[moves[i]][:power] = powers[i].to_i
      move_list[moves[i]][:accuracy] = (accuracies[i].to_i/100.00)
    end

    move_list
  end
end