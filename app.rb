require './lib/parser'
require './lib/sequence'
require './lib/job_maker'

ARGV.each do |filename|
  file_data = File.open(filename, 'r').read
  begin
    pre_jobs = Parser.new(file_data).pre_jobs
    jobs = JobMaker.new(pre_jobs).call
    sequence = Sequence.new(jobs)
    sequence.sort
    p "#{filename}: #{sequence}"
  rescue CircularDepError, PreJobNameError, PreJobDepError => e
    p "#{filename}: #{e}"
  end
end

