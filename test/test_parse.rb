require 'test/unit'
require 'test/proto/addressbook.pb'

class ParseTest < Test::Unit::TestCase
  def test_parse
    person = Tutorial::Person.new
    person.parse_from_file('test/data/data.bin')
    assert_equal(1234, person.id)
    assert_equal('John Doe', person.name)
    assert_equal('jdoe@example.com', person.email)
    assert_equal(1, person.phone.size)
    assert_equal('555-4321', person.phone[0].number)
    assert_equal(Tutorial::Person::PhoneType::HOME, person.phone[0].type)
  end

  def test_double_require
    assert_nothing_raised(Protobuf::TagCollisionError) do
      silence_warnings do
        require "#{File.dirname(__FILE__)}/proto/addressbook_redefined.pb"
      end
    end
  end

  def silence_warnings
    old_verbose, $VERBOSE = $VERBOSE, nil
    yield
  ensure
    $VERBOSE = old_verbose
  end
end
