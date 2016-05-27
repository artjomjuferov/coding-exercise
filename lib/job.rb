class Job
  attr_reader :name, :dep_job
  attr_accessor :ticket

  def initialize name, dep_job=nil
    @name = name
    # real job object
    @dep_job = dep_job
  end

  def to_s
    @name
  end
end

