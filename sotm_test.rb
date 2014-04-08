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
    assert_equal(:Perform, @power.invoke_types[0].type)
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

end



class TestActionChainGenerator < Test::Unit::TestCase
  
  # def setup
    # @initial_invoke = [:Power]
  # end
  
  # def test_empty_action_list
    # actionChainGenerator = ActionChainGenerator.new([])
    # assert_equal(0, actionChainGenerator.chains.length)
    # assert_equal("No Chains Found", actionChainGenerator.to_s)
  # end
  
  # def test_one_power_list
    # action_list = CardFactory.get_by_name("The Ardent Adept")
    # actionChainGenerator = ActionChainGenerator.new(action_list, @initial_invoke)
    # assert_equal(1, actionChainGenerator.chains.length)
    # assert_equal(1, actionChainGenerator.chains[0].length)
    # assert_equal("Chain 1:\n  The Ardent Adept, Character, Power, Execute Perform text on a card\n", actionChainGenerator.to_s)
  # end
  
  # def test_char_power_to_one_perform
    # action_list = CardFactory.get_by_name("Rhapsody of Vigor") +  CardFactory.get_by_name("The Ardent Adept")
    # actionChainGenerator = ActionChainGenerator.new(action_list, @initial_invoke)
    # assert_equal(1, actionChainGenerator.chains.length)
    
    # print "\n"
    # print actionChainGenerator.chains[0]
    # print "\n"
    
    # assert_equal(2, actionChainGenerator.chains[0].length)
       
    
    # assert_equal("Chain 1:\n" + 
                 # "  The Ardent Adept, Character, Power, Execute Perform text on a card\n" +
                 # "  Rhapsody of Vigor, Melody, Perform, Up to 5 targets regain 1 HP each\n", actionChainGenerator.to_s)

  # end
  
  # def test_char_power_to_two_perform
    # action_list = CardFactory.get_by_name("Rhapsody of Vigor") + CardFactory.get_by_name("The Ardent Adept") + CardFactory.get_by_name("Sarabande of Destruction")
    # actionChainGenerator = ActionChainGenerator.new(action_list, @initial_invoke)
    # assert_equal(2, actionChainGenerator.chains.length, "number of chains should be 2")
    # assert_equal(2, actionChainGenerator.chains[0].length, "first chain length should be 2")
    # assert_equal(2, actionChainGenerator.chains[1].length, "second chain length should be 2")
    # string_val = "Chain 1:\n" + 
                 # "  The Ardent Adept, Character, Power, Execute Perform text on a card\n" +
                 # "  Rhapsody of Vigor, Melody, Perform, Up to 5 targets regain 1 HP each\n" +
                 # "Chain 2:\n" + 
                 # "  The Ardent Adept, Character, Power, Execute Perform text on a card\n" +
                 # "  Sarabande of Destruction, Melody, Perform, Destroy 1 ongoing or environment card\n" 
    # assert_equal(string_val, actionChainGenerator.to_s)
  # end
  
end


