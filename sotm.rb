


class Action
  attr_reader :name, :card_type, :action_type, :text, :invoke_types
  
  def initialize(name, card_type, action_type, text, invoke_types = [])
    @name = name
    @card_type = card_type
    @action_type = action_type
    @text = text
    @invoke_types = invoke_types
  end
  
  def invokable?
    return invoke_types.length != 0
  end
  
  def to_s
    @name + ", " + @card_type.to_s + ", " + @action_type.to_s + ", " + text 
  end
  
  def actions_from_invoke_on(action_list)
    @out_list = []
    action_list.each do | action | 
      @invoke_types.each do | invoke | 
        @out_list << action if (invoke.type == action.action_type and (invoke.sub_type == :Any or invoke.sub_type == action.card_type))
      end
    end
    #action_list.find_all {|x| @invoke_types.include?(x.action_type)}
  end
  
  def invoke_on(action_list)
    chains = []
    invokable_actions = actions_from_invoke_on(action_list)
    invokable_actions.each do |action|
      chains << [action]
    end
    chains
  end
end

class InvokeType
  attr_reader :type, :sub_type
  
  def initialize(type, sub_type = :Any)
    @type = type
    @sub_type = sub_type
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
  
  def initialize(action_list, invoke_types = [:Power])
    @action_list = action_list
    @invoke_types = invoke_types
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
    return if @action_list.length == 0
    invokable_actions = @action_list.find_all {|x| @invoke_types.include?(x.action_type) }
    invokable_actions.each do | action | 
      if action.invokable? 
        invoke_action(action)
      else
        @chains << ActionChain.new([action])
      end
    end
  end
  
  def invoke_action(action)
    action_list_minus_current = @action_list.reject { | x | x == action }
    next_act_chain = ActionChainGenerator.new(action_list_minus_current, action.invoke_types)
    next_act_chain.generate_chains
    if next_act_chain.chains.length == 0 then
      @chains << ActionChain.new([action])
    else
      next_act_chain.chains.each { | x |  @chains << ActionChain.new([action] + x) }
    end
  end
end



class ActionSet
  
  def self.init_action_list
    @actions = []
    @actions << Action.new("The Ardent Adept", :Character, :Power, "Execute Perform text on a card", [InvokeType.new(:Perform)])
    @actions << Action.new("Rhapsody of Vigor", :Melody, :Perform, "Up to 5 targets regain 1 HP each")
    @actions << Action.new("Syncopated Onslaught", :Rhythm, :Perform, "Select up to 2 targets. until the start of your next turn increase damage death bu those targets by 1")
    @actions << Action.new("Syncopated Onslaught", :Rhythm, :Accompany, "The ardent adept deals 1 target 1 sonic damage")
    @actions << Action.new("Sarabande of Destruction", :Melody, :Perform, "Destroy 1 ongoing or environment card")
    #@actions << Action.new("Drake's Pipes", :Instrument, :Power, "Activate the Perform text of up to 2 different Melody cards")
  end
  
  def to_s
    @actions.join("\n") 
  end
  
  def self.get_by_name(name)
    init_action_list if @actions.nil?
    @actions.find_all {|x| x.name == name }
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



