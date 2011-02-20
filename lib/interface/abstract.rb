module Interface
  # When extended, this module will re-define an interface's methods to raise <tt>NotImplementedError</tt> when called (unless handled by <tt>super</tt> or <tt>method_missing</tt>)
  module Abstract
    # Returns true when this class is registering interfaces and classes for  Abstract#bad_interface and Abstract#bad_classes 
    # methods
    def self.register_classes
        @register_classes
	end
    def self.register_classes=(flag)
        @register_classes = flag
    end
	
    # Returns a hash of <tt>interfaces</tt> as keys and with a hash of <tt>classes</tt> as keys and an array of methods 
    # that the given class does not implement
    #
    # Throws exeption when register_classes was not set to true
    def self.bad_interfaces
		raise "Register classes not on. Call register classes on #{self.name}" unless register_classes 
        bad_interfaces_hash = {}
        @@interfaces.each do |interface|
            classes = interface.bad_classes 
            bad_interfaces_hash[interface] = classes unless classes.nil? or classes.empty?
        end
        bad_interfaces_hash
    end
    # Returns a hash of <tt>classes<tt> with an array of methods from the current <tt>interface</tt> 
    # that the given class does not implement
    #
    # Throws exeption when register_classes was not set to true
    def bad_classes
		raise "Register classes not on. Call register classes on Interface::Abstract" unless Abstract.register_classes 
        bad_classes_hash = {}
        @classes.each do |klass|
            methods = self.instance_methods(false).reject { |method| !klass.method_defined?(method.to_sym) || klass.instance_method(method.to_sym).owner != self }.sort
            bad_classes_hash[klass] = methods unless methods.nil? or methods.empty?
        end
        bad_classes_hash
    end
    def included(klass) # :nodoc:
      if Abstract.register_classes
	    @classes ||= []
        @classes << klass
      end
    end
    def self.extended(interface) # :nodoc:
      if Abstract.register_classes
        @@interfaces ||= []
        @@interfaces << interface
      end
      interface.class_eval do
        instance_methods(false).each do |method|
          define_method(method) do |*args, &block|
            methods = [:super, :method_missing]
            begin
              send(methods.shift, *args, &block)
            rescue NoMethodError
              if methods.empty?
                raise NotImplementedError.new("#{self.class} needs to implement '#{method}' for interface #{interface}")
              else
                args.unshift(method.to_sym)
                retry
              end
            end
          end
        end
      end
    end
  end
end
