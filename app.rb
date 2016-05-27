require './lib/parser'
require './lib/sequence'

ARGV.each do |filename|
  file_data = File.open(filename, 'r').read
  begin
    pre_jobs = Parser.new(file_data).pre_jobs
    sequence = Sequence.new(pre_jobs)
    sequence.sort
    p "#{filename}: #{sequence}"
  rescue CircularDepError, PreJobNameError, PreJobDepError => e
    p "#{filename}: #{e}"
  end
end

