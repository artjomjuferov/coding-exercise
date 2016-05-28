require './lib/sequence.rb'
require './lib/pre_job.rb'
require './lib/job_maker.rb'
require './lib/job.rb'

RSpec.describe Sequence do

  context '#min_ticket' do
    subject { Sequence.new([]).send :min_ticket, job }

    context 'when dep_ticket is nil' do
      # it's used in subject above
      let(:job) do
        dep_job = Job.new 'b'
        Job.new 'a', dep_job
      end

      it { is_expected.to be_nil }
    end

    context 'when many dependencies and tickets are not nil' do
      # it's used in subject above
      let(:job) do
        job = Job.new 'a'
        # create and assign first dependency
        dep_job1 = Job.new 'b'
        dep_job1.ticket = 1
        job.dep_jobs = dep_job1
        # create and assign second dependency
        dep_job2 = Job.new 'c'
        dep_job2.ticket = 2
        job.dep_jobs = dep_job2
        job
      end

      it { is_expected.to eq 1 }
    end

  end

  context "#to_s" do
    let(:jobs) { [Job.new('a'), Job.new('b')]}

    subject { Sequence.new(jobs).to_s }

    it { is_expected.to eq 'ab' }
  end

  context 'when there is circular error' do
    # first char is job_name
    # other chars is dependency name
    inputs = [
        %w(ab ba),
        %w(abc b ca),
        %w(ab bc cd da),
        %w(abd bc cd da),
        %w(a bc cf da e fb),
        %w(a bce cf da e fb)
    ]

    inputs.each do |input|
      it 'raises error' do
        expect{ Sequence.new make_jobs(input) }.to raise_error CircularDepError
      end
    end
  end

  context '#sort' do
    # first char is job_name
    # other chars is dependency name
    inputs = [
        %w(a),
        %w(a b c),
        %w(a bc c),
        %w(abc bc c),
        %w(a bc cf da eb f),
        %w(ab be ed df k lk ml fm),
        %w(acbe be eg cf cd fg dg dg g)
    ]

    inputs.each do |input|
      # input is array of jobs
      context "when input = #{input}" do
        let(:sequence) do
          jobs = make_jobs input
          seq = Sequence.new jobs
          seq.sort
          seq.to_s
        end

        it 'has right size' do
          # get only uniq chars
          # first join, then make array of chars, then uniq and join
          uniq_chars = input.join.chars.uniq.join
          expect(sequence.size).to eq uniq_chars.size
        end

        it 'returns right value' do
          # for checking select only with dependencies
          dep_inputs = input.select{|x| x.size >= 2}
          dep_inputs.each {|chars_jobs| check_jobs sequence, chars_jobs }
        end
      end
    end
  end


  private

  def check_jobs sequence, jobs
    # find job index
    job_ind = sequence.index jobs[0]
    # check all dependencies
    jobs[1..-1].chars.each do |job_name|
      # find dependency index
      dep_ind = sequence.index job_name
      # job has to be after its dependency
      expect(job_ind).to be > dep_ind
    end
  end

  def make_jobs input
     pre_jobs = input.flat_map do |chars|
      # first is name
      name = chars[0]
      # if it does not has dependencies create just PreJob
      if chars.size == 1
        PreJob.new(name)
      else
        chars[1..-1].chars.map do |dep_name|
          PreJob.new name, dep_name
        end
      end
    end
    JobMaker.new(pre_jobs).call
  end
end
