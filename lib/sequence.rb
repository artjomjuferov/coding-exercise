class Sequence

  def initialize jobs
    @jobs = jobs
    # validate on circular
    validate_on_circular
  end

  def sort
    @jobs.each_with_index do |job, ind|
      # if job has ticket it was visited
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
    job.dep_jobs.each do |dep_job|
      validate_dfs dep_job
    end
    # set nil after ending dfs session
    job.ticket = nil
  end


  def sort_dfs job, ticket
    return unless job
    # find min ticket from dependencies
    dep_ticket = min_ticket job
    # if it's depended on job it has to have previous ticket
    if dep_ticket
      job.ticket = dep_ticket-2
    end
    job.ticket = ticket
    job.dep_jobs.each do |dep_job|
      sort_dfs dep_job, ticket+1
    end
  end

  def min_ticket job
    job.dep_jobs
        .map(&:ticket)
        .compact
        .min
  end
end

class CircularDepError < StandardError
  def initialize
    super "There is circular dependencies"
  end
end
