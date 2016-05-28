require_relative 'job'

class JobMaker

  # pre_jobs stores just names not object
  def initialize pre_jobs
    @pre_jobs = pre_jobs
  end

  # creating graph from pre_jobs
  def call
    # create jobs without dependencies
    jobs = @pre_jobs.map{|pre_job| Job.new pre_job.name }
    jobs.each do |job|
      # find in pre_jobs all dependencies for job
      dep_pre_jobs = find_pre_jobs @pre_jobs, job.name
      dep_pre_jobs.each do |pre_job|
        # find dependency job
        dep_job = find_job jobs, pre_job.dep_name
        raise "How it could be ERROR" unless dep_job
        job.dep_jobs = dep_job
      end
    end
  end

  private

  # find only jobs with dependencies
  def find_pre_jobs pre_jobs, name
    pre_jobs.select{|job| job.name == name }
        .select{|job| job.dep_name }
  end

  def find_job jobs, name
    jobs.find{|job| job.name == name }
  end
end

