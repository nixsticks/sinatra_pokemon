class Pokemon
  attr_reader :name, :type, :learnset, :moves
  attr_writer :level, :moves

  def initialize(name, type, learnset, base_stats)
    @name = name
    @type = type
    @level = 3
    @learnset = learnset
    @moves = []
    learnset.each {|move, req_level| @moves << move if @level >= req_level}
    base_stats.each { |stat, value| instance_variable_set("@#{stat}", value) }
  end

  def level_up(new_level)
    level = new_level
    puts "#{name} grew to level #{level}!"
  end

  def learn(move)
    moves << move if learnset.keys.include?(move) && learnset[move] <= level
    puts "#{name} learned #{move}!"
  end

  def attack(move)
    if moves.include?(move)
      puts "#{name} used #{move}!"
    else
      puts "#{name} does not know that move."
    end
  end
end