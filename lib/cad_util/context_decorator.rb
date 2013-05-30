module CadUtil

  # Decorator that includes the job context as
  # a readable property
  class ContextDecorator < BasicDecorator::Decorator
    attr_reader :context
    def initialize(component, context)
      super(component)
      @context = context
    end
  end # ContextDecorator
end
