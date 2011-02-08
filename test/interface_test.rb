require 'test_helper'

module MockModule end
module MockInterface end

module Remote
  def on
  end

  def off
  end
end

class BrokenDevice
  implements Remote, MockInterface
end

class Device < BrokenDevice
  include MockModule

  def on
    @power = true
  end

  def method_missing(method, *args)
    method == :off ? @power = false : super
  end
end

class InterfaceTest < Test::Unit::TestCase

  def test_should_include_interface
    assert BrokenDevice.included_modules.include?(Remote)
  end

  def test_interface_should_include_abstract
    assert Remote.is_a?(Interface::Abstract)
  end

  def test_should_raise_not_implemented_error
    assert_raises(NotImplementedError) { BrokenDevice.new.on }
  end

  def test_should_not_raise_not_implemented_error_if_method_is_defined
    assert Device.new.on
  end

  def test_should_not_raise_not_implemented_error_if_method_is_defined_by_method_missing
    assert !Device.new.off
  end

  def test_should_return_interfaces
    assert_equal [Remote, MockInterface], Device.interfaces
  end

end