class Pokemon
  attr_reader :type, :learnset, :moves, :name
  attr_writer :name, :level, :moves, :evolution

  def initialize(name, type, learnset, base_stats, evolution)
    @name = name
    @type = type
    @level = 3
    @learnset = learnset
    @moves = []
    @evolution
    learnset.each {|move, req_level| @moves << move if @level >= req_level}
    base_stats.each { |stat, value| instance_variable_set("@#{stat}", value) }
  end

  def level_up(new_level)
    level = new_level
    puts "#{name} grew to level #{level}!"
    evolve if evolve?
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

  def evolve?
    level == evolution.values.first
  end

  def evolve
    puts "What's this?"
    sleep(0.1)
    puts "#{name} is evolving!"
    puts "#{name} evolved into #{evolution.keys.first}!"
    # evolution stuff
    
  end
end