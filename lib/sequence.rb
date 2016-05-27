require_relative 'job'

class Sequence
  #pre_jobs stores just names not object
  def initialize pre_jobs
    #creating graph from pre_jobs
    @jobs = make_jobs pre_jobs
  end


  private

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
