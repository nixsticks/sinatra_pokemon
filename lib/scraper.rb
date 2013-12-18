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
end

scraper = Scraper.new("http://bulbapedia.bulbagarden.net/wiki/Ivysaur_(Pok%C3%A9mon)")
image = scraper.get_image