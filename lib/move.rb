class Move
  attr_reader :name, :category, :type
  attr_accessor :accuracy, :power

  MOVE_LIST = YAML::load(File.open("./movelist.yaml"))

  def initialize(name)
    @name = name
    MOVE_LIST[name].each {|key, value| instance_variable_set("@#{key}", value)}
  end

  def damage(attacker, defender)
    (2 * attacker.level + 10)/250 * attacker.attack/defender.defense * power + 2
  end
end