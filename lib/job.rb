class Job
  attr_reader :name, :dep_jobs
  attr_accessor :ticket

  def initialize name, dep_job=nil
    @name = name
    # real job object
    @dep_jobs = []
    @dep_jobs << dep_job if dep_job
  end

  def dep_jobs= job
    @dep_jobs << job
  end
end

