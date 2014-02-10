require 'test/unit'
require '.\sotm.rb'

class TestAction< Test::Unit::TestCase

  def setup
    @action = ActionSet.get_by_name("Rhapsody of Vigor")[0]
  end
  def test_initialize_not_power
    assert_equal(:Melody, @action.card_type)
    assert_equal(:Perform, @action.action_type)
    assert_equal("Rhapsody of Vigor", @action.name)
    assert_equal("Up to 5 targets regain 1 HP each", @action.text)
    assert_equal([], @action.invoke_types)
    assert(!@action.invokable?)
  end
  def test_initialize_power
    @action = Action.new("The Ardent Adept", :Character, :Power, "Execute Perform text on a card", [:Perform])
    @action = ActionSet.get_by_name("The Ardent Adept")[0]
    assert_equal(:Character, @action.card_type)
    assert_equal(:Power, @action.action_type)
    assert_equal("The Ardent Adept", @action.name)
    assert_equal("Execute Perform text on a card", @action.text)
    assert_equal([:Perform], @action.invoke_types)
    assert(@action.invokable?)
  end
  def test_to_s
    assert_equal("Rhapsody of Vigor, Melody, Perform, Up to 5 targets regain 1 HP each", @action.to_s)
  end
end



class TestActionChainGenerator < Test::Unit::TestCase
  
  def test_empty_action_list
    actionChainGenerator = ActionChainGenerator.new([])
    assert_equal(0, actionChainGenerator.chains.length)
    assert_equal("No Chains Found", actionChainGenerator.to_s)
  end
  
  def test_one_power_list
    actionChainGenerator = ActionChainGenerator.new([ ActionSet.get_by_name("The Ardent Adept")[0] ])
    assert_equal(1, actionChainGenerator.chains.length)
    assert_equal(1, actionChainGenerator.chains[0].length)
    assert_equal("Chain 1:\n  The Ardent Adept, Character, Power, Execute Perform text on a card\n", actionChainGenerator.to_s)
  end
  
  def test_char_power_to_single_perform
    action_list = ActionSet.get_by_name("Rhapsody of Vigor") +  ActionSet.get_by_name("The Ardent Adept")
    actionChainGenerator = ActionChainGenerator.new(action_list)
    assert_equal(1, actionChainGenerator.chains.length)
    assert_equal(2, actionChainGenerator.chains[0].length)
    assert_equal("Chain 1:\n" + 
                 "  The Ardent Adept, Character, Power, Execute Perform text on a card\n" +
                 "  Rhapsody of Vigor, Melody, Perform, Up to 5 targets regain 1 HP each\n", actionChainGenerator.to_s)

  end
  
  def test_char_power_to_double_perform
    action_list = ActionSet.get_by_name("Rhapsody of Vigor") + ActionSet.get_by_name("The Ardent Adept") + ActionSet.get_by_name("Sarabande of Destruction")
    actionChainGenerator = ActionChainGenerator.new(action_list)
    assert_equal(2, actionChainGenerator.chains.length, "number of chains should be 2")
    assert_equal(2, actionChainGenerator.chains[0].length, "first chain length should be 2")
    assert_equal(2, actionChainGenerator.chains[1].length, "second chain length should be 2")
    string_val = "Chain 1:\n" + 
                 "  The Ardent Adept, Character, Power, Execute Perform text on a card\n" +
                 "  Rhapsody of Vigor, Melody, Perform, Up to 5 targets regain 1 HP each\n" +
                 "Chain 2:\n" + 
                 "  The Ardent Adept, Character, Power, Execute Perform text on a card\n" +
                 "  Sarabande of Destruction, Melody, Perform, Destroy 1 ongoing or environment card\n" 
    assert_equal(string_val, actionChainGenerator.to_s)

  end
  
end
