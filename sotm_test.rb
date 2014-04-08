require 'test/unit'
require '.\sotm.rb'

class TestPower < Test::Unit::TestCase

  def setup
    @power = CardFactory.get_by_name("The Ardent Adept")[0]
  end

  def test_initialize
    assert_equal(:Character, @power.card_type)
    assert_equal("The Ardent Adept", @power.name)
    assert_equal("Execute Perform text on a card", @power.text)
    assert_equal(:Perform, @power.invokes[0].action_type)
    assert_equal(:Any, @power.invokes[0].card_type)
  end 

  def test_to_s
    assert_equal("The Ardent Adept, Character, Execute Perform text on a card", @power.to_s)
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
    assert_equal("Up to 5 targets regain 1 HP each", @action.text)
  end
  
  def test_to_s
    assert_equal("Rhapsody of Vigor, Melody, Perform, Up to 5 targets regain 1 HP each", @action.to_s)
  end

  def test_is_invokable_by_base
    power = CardFactory.get_by_name("The Ardent Adept")[0]
    assert(@action.invokable_by?(power.invokes[0]))
  end

  def test_is_not_invokable_by_wrong_power
    power = CardFactory.get_by_name("Musargni's Harp")[0]
    assert(! @action.invokable_by?(power.invokes[0]))
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
    action_chain = actionChainGenerator.chains[0]
    assert_equal(2, action_chain.length, "Action chain should have two items")
    assert_equal("Chain 1:\n" + 
                 "  The Ardent Adept, Character, Execute Perform text on a card\n" +
                 "  Rhapsody of Vigor, Melody, Perform, Up to 5 targets regain 1 HP each\n", actionChainGenerator.to_s)
  end

  def test_base_power_double_card_action
    powers = [CardFactory.get_by_name("The Ardent Adept")[0]]
    actions = [CardFactory.get_by_name("Rhapsody of Vigor")[0], CardFactory.get_by_name("Sarabande of Destruction")[0]]
    actionChainGenerator = ActionChainGenerator.new(powers, actions)
    assert_equal(2, actionChainGenerator.chains.length, "There should be a two action chains")
    action_chain = actionChainGenerator.chains[0]
    assert_equal(2, action_chain.length, "First Action chain should have two items")
    action_chain = actionChainGenerator.chains[1]
    assert_equal(2, action_chain.length, "Second Action chain should have two items")
    string_val = "Chain 1:\n" + 
                 "  The Ardent Adept, Character, Execute Perform text on a card\n" +
                 "  Rhapsody of Vigor, Melody, Perform, Up to 5 targets regain 1 HP each\n" +
                 "Chain 2:\n" + 
                 "  The Ardent Adept, Character, Execute Perform text on a card\n" +
                 "  Sarabande of Destruction, Melody, Perform, Destroy 1 ongoing or environment card\n" 
    assert_equal( string_val, actionChainGenerator.to_s)               
  end
  
  def test_base_power_with_card_perf_and_accomp
    powers = [CardFactory.get_by_name("The Ardent Adept")[0]]
    actions = [] + CardFactory.get_by_name("Syncopated Onslaught")
    actionChainGenerator = ActionChainGenerator.new(powers, actions)
    assert_equal(1, actionChainGenerator.chains.length, "There should be a single action chain")
    action_chain = actionChainGenerator.chains[0]
    assert_equal(2, action_chain.length, "Action chain should have two items")
    assert_equal("Chain 1:\n" + 
                 "  The Ardent Adept, Character, Execute Perform text on a card\n" +
                 "  Syncopated Onslaught, Rhythm, Perform, Select up to 2 targets. until the start of your next turn increase damage death by those targets by 1\n", 
                 actionChainGenerator.to_s)
  end

  def test_base_power_with_card_perf_and_accomp_plus_another
    powers = [CardFactory.get_by_name("The Ardent Adept")[0]] 
    actions = [] + CardFactory.get_by_name("Syncopated Onslaught")  + CardFactory.get_by_name("Sarabande of Destruction")
    actionChainGenerator = ActionChainGenerator.new(powers, actions)
    assert_equal(2, actionChainGenerator.chains.length, "There should be a two action chains")
    action_chain = actionChainGenerator.chains[0]
    assert_equal(2, action_chain.length, "First Action chain should have two items")
    action_chain = actionChainGenerator.chains[1]
    assert_equal(2, action_chain.length, "Second Action chain should have two items")
    string_val = "Chain 1:\n" + 
                 "  The Ardent Adept, Character, Execute Perform text on a card\n" +
                 "  Syncopated Onslaught, Rhythm, Perform, Select up to 2 targets. until the start of your next turn increase damage death by those targets by 1\n" +
                 "Chain 2:\n" + 
                 "  The Ardent Adept, Character, Execute Perform text on a card\n" +
                 "  Sarabande of Destruction, Melody, Perform, Destroy 1 ongoing or environment card\n" 
    assert_equal( string_val, actionChainGenerator.to_s)               
  end

end


