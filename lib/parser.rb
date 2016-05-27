require_relative 'pre_job'

class Parser
  def initialize file_data
    @file_data = file_data
  end

  def pre_jobs
    lines = split_on_lines
    create_pre_jobs lines
  end

  private

  def split_on_lines
    # also remove all spaces
    @file_data.split("\n")
              .map{ |line| delete_spaces line }
  end

  def delete_spaces line
    line.gsub(/\s+/,'')
  end

  def create_pre_jobs lines
    lines.map do |line|
      # we should raise error if line does not match our rules
      raise LineError.new line unless valid_line? line
      name, dependency = line.split('=>')
      PreJob.new name, dependency
    end
  end

  def valid_line? line
    line =~ /^[a-z]=>[a-z]?$/
  end
end


class LineError < StandardError
  def initialize line
    msg = "'#{line}' - does not match pattern"
    super msg
  end
end

