require 'test/unit'
require '.\sotm.rb'

class TestPower < Test::Unit::TestCase
  def setup
    @power = CardFactory.get_by_name("The Ardent Adept")[0]
  end

  def test_initialize
    assert_equal(:Character, @power.card_type)
    assert_equal("The Ardent Adept", @power.name)
    assert_equal("Execute Perform text on a card.", @power.text)
    assert_equal(:Perform, @power.invokes[0].action_type)
    assert_equal(:Any, @power.invokes[0].card_type)
  end 

  def test_to_s
    assert_equal("The Ardent Adept, Character, Execute Perform text on a card.", @power.to_s)
  end

  def test_activations_from_actions_single_action
    @power = CardFactory.get_by_name("The Ardent Adept")[0]
    actions = [CardFactory.get_by_name("Rhapsody of Vigor")[0]]
    activations = @power.activations_from(actions)
    assert_equal(1, activations.length, "There should be a single activation")
    activation = activations[0]
    assert_equal(1, activation.actions.length, "Actions chain should have single item")
    assert_equal("The Ardent Adept", activation.power.name)
    assert_equal("Rhapsody of Vigor", activation.actions[0].name)
  end
end

class TestUniqueInvokePower < Test::Unit::TestCase

  def setup
    @power = CardFactory.get_by_name("Drake's Pipes")[0]
  end
  
  def test_activations_from_actions_single_action
    actions = CardFactory.get_by_name("Rhapsody of Vigor")
    activations = @power.activations_from(actions)
    assert_equal(1, activations.length, "There should be a single activation")
    activation = activations[0]
    assert_equal(1, activation.actions.length, "Actions chain should have single item")
    assert_equal("Drake's Pipes", activation.power.name)
    assert_equal("Rhapsody of Vigor", activation.actions[0].name)
  end

  def test_activations_from_actions_two_actions
    actions = CardFactory.get_by_name("Rhapsody of Vigor") + CardFactory.get_by_name("Sarabande of Destruction")
    activations = @power.activations_from(actions)
    assert_equal(4, activations.length, "There should be a four activations")
    activation = activations[0] 
    assert_equal("Drake's Pipes", activation.power.name, "Activation 1 power should be drakes pipes")
    assert_equal(1, activation.actions.length, "Activation 1 should have single item")
    assert_equal("Rhapsody of Vigor", activation.actions[0].name, "Activation 1 action 1 should be Rhapsody")
    activation = activations[1] 
    assert_equal("Drake's Pipes", activation.power.name, "Activation 2 power should be drakes pipes")
    assert_equal(2, activation.actions.length, "Activation 2 should have single item")
    assert_equal("Rhapsody of Vigor", activation.actions[0].name, "Activation 2 should have Rhapsody ")
    assert_equal("Sarabande of Destruction", activation.actions[1].name, "Activation 2 should have Sarabande")
    activation = activations[2] 
    assert_equal("Drake's Pipes", activation.power.name, "Activation 3 power should be drakes pipes")
    assert_equal(2, activation.actions.length, "Activation 3 should have single item")
    assert_equal("Sarabande of Destruction", activation.actions[0].name, "Activation 3 should have Sarabande")
    assert_equal("Rhapsody of Vigor", activation.actions[1].name, "Activation 3 should have Rhapsody ")
    activation = activations[3] 
    assert_equal("Drake's Pipes", activation.power.name, "Activation 4 power should be drakes pipes")
    assert_equal(1, activation.actions.length, "Activation 4 should have single item")
    assert_equal("Sarabande of Destruction", activation.actions[0].name, "Activation 4 should have Sarabande")
  end

  def test_activations_from_actions_two_actions_plus_bad
    actions = CardFactory.get_by_name("Rhapsody of Vigor") + CardFactory.get_by_name("Sarabande of Destruction") + CardFactory.get_by_name("Counterpoint Bulwark")
    activations = @power.activations_from(actions)
    assert_equal(4, activations.length, "There should be a four activation")
  end
  
end


class TestPowerActivation < Test::Unit::TestCase
  def test_to_s_one_action
    power = CardFactory.get_by_name("Drake's Pipes")[0]
    actions = CardFactory.get_by_name("Rhapsody of Vigor")
    activation = PowerActivation.new(power, actions)
    string_val = CardFactory.get_by_name("Drake's Pipes")[0].to_s + "\n" +
        "  " + CardFactory.get_by_name("Rhapsody of Vigor")[0].to_s + "\n"
    assert_equal(string_val, activation.to_s)
  end
  def test_to_s_two_action
    power = CardFactory.get_by_name("Drake's Pipes")[0]
    actions = CardFactory.get_by_name("Rhapsody of Vigor") + CardFactory.get_by_name("Sarabande of Destruction")
    activation = PowerActivation.new(power, actions)
    string_val = CardFactory.get_by_name("Drake's Pipes")[0].to_s + "\n" +
        "  " + CardFactory.get_by_name("Rhapsody of Vigor")[0].to_s + "\n" +
        "  " + CardFactory.get_by_name("Sarabande of Destruction")[0].to_s + "\n"
    assert_equal(string_val, activation.to_s)
  end
end

class TestActionChain < Test::Unit::TestCase
  def test_to_s_power_with_action
    actionChain = ActionChain.new( [CardFactory.get_by_name("Eydisar's Horn")[0] , CardFactory.get_by_name("Sarabande of Destruction")[0] ])
    assert_equal(
        "  " + CardFactory.get_by_name("Eydisar's Horn")[0].to_s + "\n" +
        "    " + CardFactory.get_by_name("Sarabande of Destruction")[0].to_s + "\n" ,
      actionChain.to_s)
  end

  def test_to_s_power_with_two_action
    actionChain = ActionChain.new( [CardFactory.get_by_name("Eydisar's Horn")[0] , CardFactory.get_by_name("Sarabande of Destruction")[0] ])
    assert_equal(
        "  " + CardFactory.get_by_name("Eydisar's Horn")[0].to_s + "\n" +
        "    " + CardFactory.get_by_name("Sarabande of Destruction")[0].to_s + "\n" ,
      actionChain.to_s)
  end
end

class TestAction< Test::Unit::TestCase

  def setup
    @action = CardFactory.get_by_name("Rhapsody of Vigor")[0]
  end
  
  def test_initialize
    assert_equal(:Melody, @action.card_type)
    assert_equal(:Perform, @action.action_type)
    assert_equal("Rhapsody of Vigor", @action.name)
    assert_equal("Up to 5 targets regain 1 HP each.", @action.text)
  end
  
  def test_to_s
    assert_equal("Rhapsody of Vigor, Melody, Perform, Up to 5 targets regain 1 HP each.", @action.to_s)
  end

  def test_is_invokable_by_base
    power = CardFactory.get_by_name("The Ardent Adept")[0]
    assert(@action.invokable_by?(power.invokes[0]))
  end

  def test_is_not_invokable_by_wrong_power
    power = CardFactory.get_by_name("Musargni's Harp")[0]
    assert(! @action.invokable_by?(power.invokes[0]))
  end

  def test_is_invokable_by_right_power
    power = CardFactory.get_by_name("Eydisar's Horn")[0]
    assert(@action.invokable_by?(power.invokes[0]))
  end
end

class TestActionChainGenerator < Test::Unit::TestCase

  def test_no_power_no_action_is_empty
    powers = []
    actions = []
    actionChainGenerator = ActionChainGenerator.new(powers, actions)
    assert_equal(0, actionChainGenerator.chains.length)
    assert_equal("No Chains Found", actionChainGenerator.to_s)
  end

  def test_base_power_no_action_is_empty
    powers = [CardFactory.get_by_name("The Ardent Adept")[0]]
    actions = []
    actionChainGenerator = ActionChainGenerator.new(powers, actions)
    assert_equal(0, actionChainGenerator.chains.length)
    assert_equal("No Chains Found", actionChainGenerator.to_s)
  end
  
  def test_no_power_one_action_is_empty
    powers = []
    actions = [CardFactory.get_by_name("Rhapsody of Vigor")[0]]
    actionChainGenerator = ActionChainGenerator.new(powers, actions)
    assert_equal(0, actionChainGenerator.chains.length)
    assert_equal("No Chains Found", actionChainGenerator.to_s)
  end

  def test_base_power_single_card_action
    powers = [CardFactory.get_by_name("The Ardent Adept")[0]]
    actions = [CardFactory.get_by_name("Rhapsody of Vigor")[0]]
    actionChainGenerator = ActionChainGenerator.new(powers, actions)
    assert_equal(1, actionChainGenerator.chains.length, "There should be a single action chain")
    assert_equal("Chain 1:\n" + 
                 "  The Ardent Adept, Character, Execute Perform text on a card.\n" +
                 "    Rhapsody of Vigor, Melody, Perform, Up to 5 targets regain 1 HP each.\n", actionChainGenerator.to_s)
  end

  def test_base_power_double_card_action
    powers = [CardFactory.get_by_name("The Ardent Adept")[0]]
    actions = [CardFactory.get_by_name("Rhapsody of Vigor")[0], CardFactory.get_by_name("Sarabande of Destruction")[0]]
    actionChainGenerator = ActionChainGenerator.new(powers, actions)
    assert_equal(2, actionChainGenerator.chains.length, "There should be a two action chains")
    string_val = "Chain 1:\n" + 
                 "  The Ardent Adept, Character, Execute Perform text on a card.\n" +
                 "    Rhapsody of Vigor, Melody, Perform, Up to 5 targets regain 1 HP each.\n" +
                 "Chain 2:\n" + 
                 "  The Ardent Adept, Character, Execute Perform text on a card.\n" +
                 "    Sarabande of Destruction, Melody, Perform, Destroy 1 ongoing or environment card.\n" 
    assert_equal( string_val, actionChainGenerator.to_s)               
  end
  
  def test_base_power_with_card_perf_and_accomp
    powers = [CardFactory.get_by_name("The Ardent Adept")[0]]
    actions = [] + CardFactory.get_by_name("Syncopated Onslaught")
    actionChainGenerator = ActionChainGenerator.new(powers, actions)
    assert_equal(1, actionChainGenerator.chains.length, "There should be a single action chain")
    assert_equal("Chain 1:\n" + 
                 "  The Ardent Adept, Character, Execute Perform text on a card.\n" +
                 "    Syncopated Onslaught, Rhythm, Perform, Select up to 2 targets. Until the start of your next turn increase damage death by those targets by 1.\n", 
                 actionChainGenerator.to_s)
  end

  def test_base_power_with_card_perf_and_accomp_plus_another
    powers = [CardFactory.get_by_name("The Ardent Adept")[0]] 
    actions = [] + CardFactory.get_by_name("Syncopated Onslaught")  + CardFactory.get_by_name("Sarabande of Destruction")
    actionChainGenerator = ActionChainGenerator.new(powers, actions)
    assert_equal(2, actionChainGenerator.chains.length, "There should be a two action chains")
    string_val = "Chain 1:\n" + 
                 "  The Ardent Adept, Character, Execute Perform text on a card.\n" +
                 "    Syncopated Onslaught, Rhythm, Perform, Select up to 2 targets. Until the start of your next turn increase damage death by those targets by 1.\n" +
                 "Chain 2:\n" + 
                 "  The Ardent Adept, Character, Execute Perform text on a card.\n" +
                 "    Sarabande of Destruction, Melody, Perform, Destroy 1 ongoing or environment card.\n" 
    assert_equal( string_val, actionChainGenerator.to_s)               
  end
  
   def test_base_power_with_card_two_perf
    powers = [CardFactory.get_by_name("The Ardent Adept")[0]] 
    actions = [] + CardFactory.get_by_name("Syncopated Onslaught")  + CardFactory.get_by_name("Sarabande of Destruction")
    actionChainGenerator = ActionChainGenerator.new(powers, actions)
    assert_equal(2, actionChainGenerator.chains.length, "There should be a two action chains")
    string_val = "Chain 1:\n" + 
                 "  The Ardent Adept, Character, Execute Perform text on a card.\n" +
                 "    Syncopated Onslaught, Rhythm, Perform, Select up to 2 targets. Until the start of your next turn increase damage death by those targets by 1.\n" +
                 "Chain 2:\n" + 
                 "  The Ardent Adept, Character, Execute Perform text on a card.\n" +
                 "    Sarabande of Destruction, Melody, Perform, Destroy 1 ongoing or environment card.\n" 
    assert_equal( string_val, actionChainGenerator.to_s)               
  end

  def test_power_with_two_invoke_with_one_perform
    powers = [] + CardFactory.get_by_name("Eydisar's Horn")
    actions = [] + CardFactory.get_by_name("Sarabande of Destruction")
    actionChainGenerator = ActionChainGenerator.new(powers, actions)
    assert_equal(1, actionChainGenerator.chains.length, "There should be a single action chain")
    string_val = "Chain 1:\n" + 
                 "  " + CardFactory.get_by_name("Eydisar's Horn")[0].to_s + "\n" +
                 "    " + CardFactory.get_by_name("Sarabande of Destruction")[0].to_s + "\n"
    assert_equal( string_val, actionChainGenerator.to_s)               
  end

  def test_power_with_one_perform_can_do_plus_extra
    powers = [] + CardFactory.get_by_name("Eydisar's Horn")
    actions = [] + CardFactory.get_by_name("Syncopated Onslaught")  + CardFactory.get_by_name("Sarabande of Destruction")
    actionChainGenerator = ActionChainGenerator.new(powers, actions)
    assert_equal(1, actionChainGenerator.chains.length, "There should be a single action chain")
    string_val = "Chain 1:\n" + 
                 "  " + CardFactory.get_by_name("Eydisar's Horn")[0].to_s + "\n" +
                 "    " + CardFactory.get_by_name("Sarabande of Destruction")[0].to_s + "\n"
    assert_equal( string_val, actionChainGenerator.to_s)               
  end
  
  def test_two_powers_with_one_perform
    powers = [] + CardFactory.get_by_name("Eydisar's Horn") + CardFactory.get_by_name("The Ardent Adept")
    actions = [] + CardFactory.get_by_name("Sarabande of Destruction")
    actionChainGenerator = ActionChainGenerator.new(powers, actions)
    assert_equal(2, actionChainGenerator.chains.length, "There should be a two action chains")
    activation = actionChainGenerator.chains[0]
    assert_equal(1, activation.actions.length, "First activation should have one action")
    activation = actionChainGenerator.chains[1]
    assert_equal(1, activation.actions.length, "First activation should have one action")
    string_val = "Chain 1:\n" + 
                 "  " + CardFactory.get_by_name("Eydisar's Horn")[0].to_s + "\n" +
                 "    " + CardFactory.get_by_name("Sarabande of Destruction")[0].to_s + "\n" +
                "Chain 2:\n" + 
                 "  " + CardFactory.get_by_name("The Ardent Adept")[0].to_s + "\n" +
                 "    " + CardFactory.get_by_name("Sarabande of Destruction")[0].to_s + "\n"
    assert_equal( string_val, actionChainGenerator.to_s)               
  end

  # def test_one_power_with_two_invokes_drake_pipe_details
    # powers = [] + CardFactory.get_by_name("Drake's Pipes") 
    # actions = [] + CardFactory.get_by_name("Sarabande of Destruction")
    # actionChainGenerator = ActionChainGenerator.new(powers, actions)
    # assert_equal(1, actionChainGenerator.chains.length, "There should be a single action chain")
    # action_chain = actionChainGenerator.chains[0]
    # assert_equal(3, action_chain.length, "First Action chain should have four items")
    # string_val = "Chain 1:\n" + 
                 # "  " + CardFactory.get_by_name("Drake's Pipes")[0].to_s + "\n" +
                 # "    " + CardFactory.get_by_name("Sarabande of Destruction")[0].to_s + "\n" 
    # assert_equal( string_val, actionChainGenerator.to_s)
  # end
  
  # def test_two_power_with_two_invokes_drake_pipe_details
    # powers = [] + CardFactory.get_by_name("Drake's Pipes") + CardFactory.get_by_name("The Ardent Adept")
    # actions = [] + CardFactory.get_by_name("Sarabande of Destruction")
    # actionChainGenerator = ActionChainGenerator.new(powers, actions)
    # assert_equal(2, actionChainGenerator.chains.length, "There should be a two action chains")
    # string_val = "Chain 1:\n" + 
                 # "  " + CardFactory.get_by_name("Drake's Pipes")[0].to_s + "\n" +
                 # "    " + CardFactory.get_by_name("Sarabande of Destruction")[0].to_s + "\n" +
                # "Chain 2:\n" + 
                 # "  " + CardFactory.get_by_name("The Ardent Adept")[0].to_s + "\n" +
                 # "    " + CardFactory.get_by_name("Sarabande of Destruction")[0].to_s + "\n"
    # assert_equal( string_val, actionChainGenerator.to_s)
    # print "\n" + actionChainGenerator.to_s + "\n"
  # end

end
