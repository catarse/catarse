module ProjectExtensions
  extend ActiveSupport::Concern

  included do
    singleton_class.prepend ClassMethods
    prepend InstanceMethods
  end

  module ClassMethods
    # def some_class_method
    #    ...
    # end
  end

  module InstanceMethods
    def using_pagarme?
      return false
       # # do before work
       # original_result = super # do original work
       # # do after work
       # return original_result
     end
     # def new_instance_method
     #   # do something new
     # end
  end
end
Project.include ProjectExtensions