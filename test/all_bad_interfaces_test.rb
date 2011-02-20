require 'test_helper'

class AllBadInterfacesTest < Test::Unit::TestCase
  def setup
	
	Interface::Abstract.register_classes = true
	
    @mock_module = mock_module = Module.new
    @mock_interface = mock_interface = Module.new
    @remote = remote = Module.new { attr_reader :on, :off; def on?; end }
    @broken_device = Class.new { def on?; !!@power end; implements remote, mock_interface }
    @device = Class.new(@broken_device) do
      include mock_module

      def on
        @power = true
      end

      def method_missing(method, *args)
        method == :off ? @power = false : super
      end

      def respond_to_missing?(method, include_private)
        method == :off || super
      end
    end
  end
  def test_bad_classes_on_interface
	assert_equal({ @broken_device => ['off', 'on'] }, @remote.bad_classes)
	assert_equal({}, @mock_interface.bad_classes)
  end
  def test_all_bad_classes
	assert_equal({@remote => { @broken_device => ['off', 'on'] }}, Interface::Abstract.bad_interfaces)
	assert_equal({}, @mock_interface.bad_classes)
  end
end
