require 'nokogiri'
require 'open-uri'

class Scraper
  attr_reader :html

  def initialize(url)
    @html = Nokogiri::HTML(open(url))
  end

  def first_stage_url
    html.xpath('//h2[contains(span, "List of Pokémon by evolution family")]/following::table//tr/td[2]/a[contains(@title, "(Pokémon)")]').map { |link| "http://bulbapedia.bulbagarden.net" + link['href'] }
  end

  def second_stage_url
    html.xpath('//h2[contains(span, "List of Pokémon by evolution family")]/following::table[following::h2[contains(span, "Trivia")]]//tr[contains(th, "family")]/following-sibling::tr[1]/td[5]').map do |family|
      "http://bulbapedia.bulbagarden.net" + family.search('a')[0]['href']
    end
  end

  def third_stage_url
    html.xpath('//h2[contains(span, "List of Pokémon by evolution family")]/following::table[following::h2[contains(span, "Trivia")]]//tr[contains(th, "family")]/following-sibling::tr[1]/td[8]').map do |family|
      "http://bulbapedia.bulbagarden.net" + family.search('a')[0]['href']
    end
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

  def get_first_evolution
    level = html.search('//h3[contains(span, "Evolution")]/following::table[1]//td/a[contains(span, "Level")]')
    species = html.search('//h3[contains(span, "Evolution")]/following::table[1]//td/a[contains(@title, "Pokémon")]')

    unless level.empty? || species.empty? || level.nil? || species.nil?
      level = level.first.text
      species = species.first.text
      level_digit = /^Level (\d+)$/.match(level)
      {species => level_digit[1].to_i} if level_digit
    end
  end

  def get_second_evolution
    level = html.search('//h3[contains(span, "Evolution")]/following::table[1]//td/a[contains(span, "Level")]')
    species = html.search('//h3[contains(span, "Evolution")]/following::table[1]//td/a[contains(@title, "Pokémon")]')

    unless level.empty? || species.empty? || level.nil? || species.nil?
      if level[1] && species[1]
        level = level[1].text
        species = species[1].text
        level_digit = /^Level (\d+)$/.match(level)
        {species => level_digit[1].to_i} if level_digit
      end
    end
  end
end
