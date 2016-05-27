require './lib/sequence.rb'
require './lib/pre_job.rb'

RSpec.describe Sequence do

  context '#make_jobs' do
    subject { Sequence.new(pre_jobs).send(:make_jobs, pre_jobs) }

    context 'when job has single dependency' do
      # it's used in subject above
      let(:pre_jobs) { [PreJob.new('a', 'b'), PreJob.new('b')]}

      it { is_expected.to be_an Array}

      it 'returns array of jobs' do
        arr = subject
        arr.each do |job|
          expect(job).to be_a Job
        end
      end

      it 'returns array with Job "a"' do
        job_a = subject[0]
        expect(job_a.name).to eq 'a'
      end

      it 'returns array with Job "a" depended on "b"' do
        job_a = subject[0]
        expect(job_a.dep_jobs[0].name).to eq 'b'
      end
    end

    context 'when job has many dependencies' do
      # it's used in subject above
      let(:pre_jobs) {
        [
          PreJob.new('a', 'b'),
          PreJob.new('a', 'c'),
          PreJob.new('b'),
          PreJob.new('c')
        ]
      }

      context 'when everything is correct' do
        it { is_expected.to be_an Array}

        it 'returns array of jobs' do
          arr = subject
          arr.each do |job|
            expect(job).to be_a Job
          end
        end

        it 'returns array with Job "a"' do
          job_a = subject[0]
          expect(job_a.name).to eq 'a'
        end

        it 'returns array with Job "a" depended on "b"' do
          job_a = subject[0]
          expect(job_a.dep_jobs[0].name).to eq 'b'
        end

        it 'returns array with Job "a" depended on "c"' do
          job_a = subject[0]
          expect(job_a.dep_jobs[1].name).to eq 'c'
        end
      end
    end
  end


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
    let(:pre_jobs) { [PreJob.new('a'), PreJob.new('b')]}

    subject { Sequence.new(pre_jobs).to_s }

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
        expect{ Sequence.new make_pre_jobs(input) }.to raise_error CircularDepError
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
        %w(ab be ed df k lk ml fm)
    ]

    inputs.each do |input|
      context "when input = #{input}" do
        it 'returns right value' do
          # create from input pre_jobs
          pre_jobs = make_pre_jobs input
          seq = Sequence.new pre_jobs
          seq.sort
          # for checking select only with dependencies
          dep_inputs = input.select{|x| x.size > 2}
          dep_inputs.each {|jobs| check_jobs seq, jobs }
        end
      end
    end
  end


  private

  def check_jobs seq, jobs
    # get sequence result
    sequence = seq.to_s
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

  def make_pre_jobs input
    input.flat_map do |chars|
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
  end
end
