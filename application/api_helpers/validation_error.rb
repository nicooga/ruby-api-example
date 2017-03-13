class Api::ValidationError < StandardError
  attr_accessor :errors

  def initialize(errors)
    self.errors = errors
  end
end
