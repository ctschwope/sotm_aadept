
# powers invoke actions (1 or 2)
# an action may queue up a power
# lets make those seperate things


class Power
  attr_reader :name, :card_type, :text, :invokes
  
  def initialize(name, card_type, text, invokes = [])
    @name = name
    @card_type = card_type
    @text = text
    @invokes = invokes
  end

  def to_s
    @name + ", " + @card_type.to_s + ", " + text 
  end

end

class Action
  attr_reader :name, :card_type, :action_type, :text
  
  def initialize(name, card_type, action_type, text)
    @name = name
    @card_type = card_type
    @action_type = action_type
    @text = text
  end
  
  def to_s
    @name + ", " + @card_type.to_s + ", " + @action_type.to_s + ", " + text 
  end
  
  def invokable_by?(invoke)
    invoke.action_type == @action_type and (invoke.card_type == :Any or invoke.card_type == @card_type)
  end
  
end

class Invoke
  attr_reader :action_type, :card_type
  
  def initialize(action_type, card_type = :Any)
    @action_type = action_type
    @card_type = card_type
  end
  
  def to_s
    @type.to_s + " - " + @sub_type.to_s
  end
end

class ActionChain < Array
  
  def to_s
    out_str = ""
    self.each do | action | 
      out_str += "  " + action.to_s + "\n"
    end
    out_str
  end
end

class ActionChainGenerator
  attr_reader :chains
  
  def initialize(power_list, action_list)
    @power_list = power_list
    @action_list = action_list
  end
  
  def to_s
    return "No Chains Found" if @chains.length == 0
    out_str = ""
    @chains.each_with_index do |chain, index| 
      out_str += "Chain " + (index + 1).to_s + ":\n" + chain.to_s
    end
    out_str
  end
  
  def chains 
    generate_chains if @chains.nil?
    @chains
  end
  
  def generate_chains
    @chains = []
    return if (@action_list.length == 0 or @power_list.length == 0)
    
    # assuming single power for a second
    power = @power_list[0]
    invokable_actions = @action_list.find_all {| action | action.invokable_by?(power.invokes[0]) }
    
    invokable_actions.each do | action |
      @chains << ActionChain.new([power, action])
    end
    
  end
  
  def invoke_action(action)
    action_list_minus_current = @action_list.reject { | x | x == action }
    next_act_chain = ActionChainGenerator.new(action_list_minus_current, action.invokes)
    next_act_chain.generate_chains
    if next_act_chain.chains.length == 0 then
      @chains << ActionChain.new([action])
    else
      next_act_chain.chains.each { | x |  @chains << ActionChain.new([action] + x) }
    end
  end
end


class CardFactory
  def self.init_action_list
    @cards = []
    @cards << Power.new("The Ardent Adept", :Character, "Execute Perform text on a card", [Invoke.new(:Perform)])
    @cards << Action.new("Rhapsody of Vigor", :Melody, :Perform, "Up to 5 targets regain 1 HP each")
    @cards << Action.new("Syncopated Onslaught", :Rhythm, :Perform, "Select up to 2 targets. until the start of your next turn increase damage death bu those targets by 1")
    @cards << Action.new("Syncopated Onslaught", :Rhythm, :Accompany, "The ardent adept deals 1 target 1 sonic damage")
    @cards << Action.new("Sarabande of Destruction", :Melody, :Perform, "Destroy 1 ongoing or environment card")
    #@actions << Action.new("Drake's Pipes", :Instrument, :Power, "Activate the Perform text of up to 2 different Melody cards")
    @cards << Power.new("Musargni's Harp", :Instrument, "Activate the Perform text on a Harmony Card and activate the Accompany text on a Harmony Card", [Invoke.new(:Perform,:Harmony), Invoke.new(:Accompany,:Harmony)])
  end
  
  def to_s
    @cards.join("\n") 
  end
  
  def self.get_by_name(name)
    init_action_list if @actions.nil?
    @cards.find_all {|x| x.name == name }
  end
end

def SingleRun
  
  def initialize
    @actionHolder = ActionHolder.new
    @powers = @actionHolder.actions.find_all {|x| x.action_type = :Power }
    @usedPowers = []
  end

  def GetRunString
    
  end
end



# select power
# trigger power
# if does another power, select power again, repeat, removing power form possuble lists

#actionHolder =  ActionHolder.new
#powers = actionHolder.actions.find_all{| x | x.action_type == :Power }
#print powers.to_s
#print "\n\n"
#print actionHolder.to_s + "\n"
#print "\n\n"



