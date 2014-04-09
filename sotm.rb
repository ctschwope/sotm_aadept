
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

   def chains_from_actions(actions)
    chains = []
    invokable_actions = actions.find_all {| action | action.invokable_by?(@invokes[0]) }

    invokable_actions.each do | action |
      chains << ActionChain.new([self, action])
    end
    chains
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
    @action_type.to_s + " - " + @card_type.to_s
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
    
    @power_list.each do | power | 
      @chains = @chains + power.chains_from_actions(@action_list)
    end
    return 
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
    @cards << Power.new("The Ardent Adept", :Character, "Execute Perform text on a card.", [Invoke.new(:Perform)])
    @cards << Power.new("Drake's Pipes", :Instrument, "Activate the Perform text of up to 2 different Melody cards.", 
                            [Invoke.new(:Perform,:Melody), Invoke.new(:Perform,:Melody)])
    @cards << Power.new("Eydisar's Horn", :Instrument, "Activate the Perform text on a Melody Card and the Accompany text on a Harmony Card.", 
                            [Invoke.new(:Perform,:Melody), Invoke.new(:Accompany,:Harmony)])
    @cards << Power.new("Xu's Bell", :Instrument, "Activate the Perform text on a Rythm Card and the Accompany text on either a Harmony or Rhythm Card.", 
                            [Invoke.new(:Perform,:Rhythm), Invoke.new(:Accompany,:HarmonyRythm)])
    @cards << Power.new("Musargni's Harp", :Instrument, "Activate the Perform text on a Harmony Card and the Accompany text on a Harmony Card.", 
                            [Invoke.new(:Perform,:Harmony), Invoke.new(:Accompany,:Harmony)])
    @cards << Power.new("Telamon's Lyra", :Instrument, "Activate the Perform text on a Harmony Card and the Accompany text on a Rhythm Card.", 
                            [Invoke.new(:Perform,:Harmony), Invoke.new(:Accompany,:Rythm)])
    @cards << Power.new("Akpunku's Drum", :Instrument, "Activate the Accompany text on a Rhythm Card and the Perform text on a Melody Card.", 
                            [Invoke.new(:Accompany,:Rythm), Invoke.new(:Perform,:Melody)])
                            
    @cards << Action.new("Rhapsody of Vigor", :Melody, :Perform, "Up to 5 targets regain 1 HP each.")

    @cards << Action.new("Sarabande of Destruction", :Melody, :Perform, "Destroy 1 ongoing or environment card.")

    @cards << Action.new("Syncopated Onslaught", :Rhythm, :Perform, "Select up to 2 targets. Until the start of your next turn increase damage death by those targets by 1.")
    @cards << Action.new("Syncopated Onslaught", :Rhythm, :Accompany, "The Ardent Adept deals 1 target 1 sonic damage.")

    @cards << Action.new("Alacritous Subdominant", :Harmony, :Perform, "One player may play 1 card now.")
    @cards << Action.new("Alacritous Subdominant", :Harmony, :Accompany, "You may use a power now. If you do, destroy this card.")

    @cards << Action.new("Inspiring Supertonic", :Harmony, :Perform, "One player may us a power now.")
    @cards << Action.new("Inspiring Supertonic", :Harmony, :Accompany, "The Ardent Adept regains 2 HP.")

    @cards << Action.new("Scherzo of Frost and Flame", :Melody, :Perform, "The Ardent Adept deals one target 1 cold damage, then deals 1 target 1 fire damage.") 

    @cards << Action.new("Inventive preparation", :Rhythm, :Perform, "Each player may look at the top card of their hero deck then replace or discard it.")
    @cards << Action.new("Inventive preparation", :Rhythm, :Accompany, "One player other than you may play 1 card now.")

    @cards << Action.new("Cedistic Dissonant", :Harmony, :Perform, "Destroy an instrument. If you do, destroy and 1 card in play other than a character card.")
    @cards << Action.new("Cedistic Dissonant", :Harmony, :Accompany, "Discard 2 cards. Draw 3 cards.")

    @cards << Action.new("Counterpoint Bulwark", :Rhythm, :Perform, "Select up to 2 targets. Until start of your next turn, reduce damage death to those targets by 1.")
    @cards << Action.new("Counterpoint Bulwark", :Rhythm, :Accompany, "One player may draw 1 card now.")


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



