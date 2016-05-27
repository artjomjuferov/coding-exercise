require_relative 'job'

class Sequence

  #pre_jobs stores just names not object
  def initialize pre_jobs
    #creating graph from pre_jobs
    @jobs = make_jobs pre_jobs
    # validate on circular
    validate_on_circular
  end

  def sort
    @jobs.each_with_index do |job, ind|
      # if job has ticket it was marked
      next if job.ticket
      sort_dfs job, ind*@jobs.size
    end
    # now every job has their own right ticket
    @jobs = @jobs.sort_by(&:ticket).reverse
  end

  def to_s
    @jobs.inject(''){|result, job| result += job.name.to_s }
  end

  private

  def validate_on_circular
    @jobs.each do |job|
      next if job.ticket
      validate_dfs job
    end
  end

  def validate_dfs job
    return unless job
    # if we during this dfs have visited this edge it's circular
    raise CircularDepError if job.ticket
    job.ticket = true
    validate_dfs job.dep_job
    # set nil after ending dfs session
    job.ticket = nil
  end


  def sort_dfs job, ticket
    return unless job

    # if it's depended on job it has to have previous ticket
    if job.dep_job and job.dep_job.ticket
        job.ticket = job.dep_job.ticket-2
    end
    job.ticket = ticket
    sort_dfs job.dep_job, ticket+1
  end


  def make_jobs pre_jobs
    # create jobs without dependencies
    jobs = pre_jobs.map{|pre_job| Job.new pre_job.name }
    jobs.each do |job|
      # find in pre_jobs dependency job name
      pre_job = find_job pre_jobs, job.name
      next if !pre_job or !pre_job.dep_name
      # find dependency job
      dep_job = find_job jobs, pre_job.dep_name
      raise "How it could be ERROR" unless dep_job
      job.dep_job = dep_job
    end
  end

  def find_job jobs, name
    jobs.find{ |job| job.name == name }
  end
end

class CircularDepError < StandardError
  def initialize
    super "There is circular dependencies"
  end
end
