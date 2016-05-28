class PreJob
  attr_reader :name, :dep_name

  def initialize name, dep_name=nil
    @name     = name
    @dep_name = dep_name
    validation
  end


  private

  # simple validations
  def validation
    unless valid_dependency?
      raise PreJobDepError, @name
    end
  end

  # can't be depended on itself
  def valid_dependency?
    @name != @dep_name
  end
end


class PreJobDepError < StandardError
  def initialize name
    super "ERROR: '#{name}' can't depend on itself"
  end
end