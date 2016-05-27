class PreJob
  attr_reader :name, :dep_name

  def initialize name, dep_name=nil
    @name     = name
    @dep_name = dep_name
    validation
  end

  def to_s; @name; end


  private

  # simple validations
  def validation
    validate_name @name
    validate_name @dep_name if @dep_name
    raise PreJobDepError, @name unless valid_dependency?
  end

  def validate_name name
    unless ('a'..'z').include? name
      raise PreJobNameError, name
    end
  end

  #can't be depended on itself
  def valid_dependency?
    @name != @dep_name
  end
end


class PreJobNameError < StandardError
  def initialize wrong_name
    super "'#{wrong_name}' is wrong, only a-z available"
  end
end

class PreJobDepError < StandardError
  def initialize name
    super "'#{name}' can't depend on itself"
  end
end