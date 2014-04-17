
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

   def is_power?
    true
   end
   
   def <=>(other)
    @name <=> other.name
   end
end

class UniqueInvokePower < Power

  def activations_from_single_invokable_list(invokable_actions)
    activations = []
    invokable_actions.each do | action | 
      activations << PowerActivation.new(self, [action])
    end
    activations
  end
  
  def activations_from(actions)
    activations = []
    invokable_actions = []

    @invokes.each do | invoke |
      invokable_actions << actions.find_all {| action | action.invokable_by?(invoke) }
    end
    
    if (@invokes.length == 1 or invokable_actions[1].length == 0) then
      activations = activations_from_single_invokable_list(invokable_actions[0])
    elsif (invokable_actions[0].length == 0) then
      activations = activations_from_single_invokable_list(invokable_actions[1])
    else
      invokable_actions[0].each do | first_action | 
        invokable_actions[1].each do | second_action | 
          if first_action == second_action then
            activations << PowerActivation.new(self, [first_action])
          else
            activations << PowerActivation.new(self, [first_action, second_action])
          end
        end
      end
    end
    activations
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
    return invoke.can_invoke?(self)
  end

  def is_power?
    false
  end
  def <=>(other)   
    return @name <=> other.name if @name != other.name 
    return 0 if (@action_type == other.action_type)
    @action_type == :Perform ? -1 : 1 
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
  
  def can_invoke?(action)
    action.action_type == @action_type and
      (@card_type == :Any or @card_type == action.card_type)
  end
end

class MultiCardTypeInvoke
  attr_reader :action_type, :card_types
  
  def initialize(action_type, card_types = [:Any])
    @action_type = action_type
    @card_types = card_types
  end
  
  def to_s
    @action_type.to_s + " - " + @card_types.to_s
  end
  
  def can_invoke?(action)
    action.action_type == @action_type and
      (@card_type == :Any or @card_types.include?(action.card_type))
  end
end


class ActionChain < Array
  def to_s
    out_str = ""
    indent = 1
    self.each do | action | 
      out_str += ("  " * indent) + action.to_s + "\n"
      indent += 1 if action.is_power?
    end
    out_str
  end
end

class PowerActivation 
  attr_reader :power, :actions
  
  def initialize(power, actions = [])
    @power = power
    @actions = actions
  end
  
  def to_s
    out_str = @power.to_s + "\n"
    @actions.each do | action | 
      out_str += "  " + action.to_s + "\n"
    end
    out_str
  end
  
  def ==(other)
    @power == other.power and @actions == other.actions
  end
end

class ActionChainGenerator
  
  def initialize(power_list, action_list)
    @power_list = power_list
    @action_list = action_list
  end
  
  def to_s
    generate_chains if @chains.nil?
    return "No Chains Found" if @chains.length == 0
    out_str = ""
    @chains.each_with_index do |chain, index| 
      out_str += "Chain " + (index + 1).to_s + ":\n" 
      chain.to_s.lines { |line| out_str += "  " + line }
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
      @chains = @chains + power.activations_from(@action_list)
    end
    return 
  end
 
end


class CardFactory
  def self.init_action_list
    @powers = []
    @powers << UniqueInvokePower.new("The Ardent Adept", :Character, "Execute Perform text on a card.", [Invoke.new(:Perform)])
    @powers << UniqueInvokePower.new("Drake's Pipes", :Instrument, "Activate the Perform text of up to 2 different Melody cards.", 
                            [Invoke.new(:Perform,:Melody), Invoke.new(:Perform,:Melody)])
    @powers << UniqueInvokePower.new("Eydisar's Horn", :Instrument, "Activate the Perform text on a Melody Card and the Accompany text on a Harmony Card.", 
                            [Invoke.new(:Perform,:Melody), Invoke.new(:Accompany,:Harmony)])
    @powers << UniqueInvokePower.new("Xu's Bell", :Instrument, "Activate the Perform text on a Rythm Card and the Accompany text on either a Harmony or Rhythm Card.", 
                            [Invoke.new(:Perform,:Rhythm), MultiCardTypeInvoke.new(:Accompany, [:Harmony, :Rhythm])])
    @powers << UniqueInvokePower.new("Musargni's Harp", :Instrument, "Activate the Perform text on a Harmony Card and the Accompany text on a Harmony Card.", 
                            [Invoke.new(:Perform,:Harmony), Invoke.new(:Accompany,:Harmony)])
    @powers << UniqueInvokePower.new("Telamon's Lyra", :Instrument, "Activate the Perform text on a Harmony Card and the Accompany text on a Rhythm Card.", 
                            [Invoke.new(:Perform,:Harmony), Invoke.new(:Accompany,:Rhythm)])
    @powers << UniqueInvokePower.new("Akpunku's Drum", :Instrument, "Activate the Accompany text on a Rhythm Card and the Perform text on a Melody Card.", 
                            [Invoke.new(:Accompany,:Rhythm), Invoke.new(:Perform,:Melody)])
                            
    @powers = @powers.sort
    
    @actions = []                              
    @actions << Action.new("Rhapsody of Vigor", :Melody, :Perform, "Up to 5 targets regain 1 HP each.")

    @actions << Action.new("Sarabande of Destruction", :Melody, :Perform, "Destroy 1 ongoing or environment card.")

    @actions << Action.new("Syncopated Onslaught", :Rhythm, :Perform, "Select up to 2 targets. Until the start of your next turn increase damage death by those targets by 1.")
    @actions << Action.new("Syncopated Onslaught", :Rhythm, :Accompany, "The Ardent Adept deals 1 target 1 sonic damage.")

    @actions << Action.new("Alacritous Subdominant", :Harmony, :Perform, "One player may play 1 card now.")
    @actions << Action.new("Alacritous Subdominant", :Harmony, :Accompany, "You may use a power now. If you do, destroy this card.")

    @actions << Action.new("Inspiring Supertonic", :Harmony, :Perform, "One player may us a power now.")
    @actions << Action.new("Inspiring Supertonic", :Harmony, :Accompany, "The Ardent Adept regains 2 HP.")

    @actions << Action.new("Scherzo of Frost and Flame", :Melody, :Perform, "The Ardent Adept deals one target 1 cold damage, then deals 1 target 1 fire damage.") 

    @actions << Action.new("Inventive Preparation", :Rhythm, :Perform, "Each player may look at the top card of their hero deck then replace or discard it.")
    @actions << Action.new("Inventive Preparation", :Rhythm, :Accompany, "One player other than you may play 1 card now.")

    @actions << Action.new("Cedistic Dissonant", :Harmony, :Perform, "Destroy an instrument. If you do, destroy and 1 card in play other than a character card.")
    @actions << Action.new("Cedistic Dissonant", :Harmony, :Accompany, "Discard 2 cards. Draw 3 cards.")

    @actions << Action.new("Counterpoint Bulwark", :Rhythm, :Perform, "Select up to 2 targets. Until start of your next turn, reduce damage death to those targets by 1.")
    @actions << Action.new("Counterpoint Bulwark", :Rhythm, :Accompany, "One player may draw 1 card now.")

    @actons = @actions.sort
  end
  
  def to_s
    @cards.join("\n") + @actons.join("\n")
  end
  
  def self.get_by_name(name)
    init_action_list if @actions.nil? 
    (@actions + @powers).find_all {|x| x.name == name }.sort 
  end
  
  def self.get_by_action_type(action_type)
    @actions.find_all {|x| x.action_type == action_type }.sort
  end

  def self.get_by_card_type(card_type)
    @actions.find_all {|x| x.card_type == card_type }.sort
  end
  
  def self.actions
    @actions.sort
  end

end
