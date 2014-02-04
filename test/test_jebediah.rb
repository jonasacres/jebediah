require 'test/unit'
require 'jebediah'

$jeb =Jebediah.new()
class JebediahTest < Test::Unit::TestCase
  

  def test_hash_int_to_phrase
    assert_equal ["chipperly", "divided", "snake"], $jeb.phraseForHash(19090108)
  end

  def test_hash_str_to_phrase
    assert_equal ["chipperly", "divided", "snake"], $jeb.phraseForHash("1234abc")
  end

  def test_hash_hex_to_phrase
    assert_equal ["chipperly", "divided", "snake"], $jeb.phraseForHash("0x1234abc")
  end

  def test_hash_illegal
    assert_equal nil, $jeb.phraseForHash("illegal")
  end

  def test_phrase_array_to_hash
    assert_equal "1234abc", $jeb.hashForPhrase(["chipperly", "divided", "snake"])
  end

  def test_phrase_str_to_hash
    assert_equal "1234abc", $jeb.hashForPhrase("chipperly divided snake")
  end

  def test_phrase_illegal_length
    assert_equal nil, $jeb.hashForPhrase(["chipperly", "divided"])
  end

  def test_phrase_illegal_word
    assert_equal nil, $jeb.hashForPhrase(["chipperly", "chipperly", "snake"])
  end

  def test_process_hash_str
    assert_equal( { :type => 'phrase', :result => ['chipperly', 'divided', 'snake'] }, $jeb.process("1234abc"))
  end

  def test_process_hash_arr
    assert_equal( { :type => 'phrase', :result => ['chipperly', 'divided', 'snake'] }, $jeb.process(["1234abc"]))
  end

  def test_process_phrase_str
    assert_equal( { :type => 'hash', :result => '1234abc' }, $jeb.process("chipperly divided snake"))
  end

  def test_process_phrase_arr
    assert_equal( { :type => 'hash', :result => '1234abc' }, $jeb.process(["chipperly", "divided", "snake"]))
  end

  def test_process_phrase_illegal_length
    assert_equal( { :type => 'error' }, $jeb.process(["chipperly", "divided"]))
  end

  def test_process_phrase_illegal_word
    assert_equal( { :type => 'error' }, $jeb.process(["chipperly", "chipperly", "snake"]))
  end
end
