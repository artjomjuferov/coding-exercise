require './lib/sequence.rb'
require './lib/pre_job.rb'

RSpec.describe Sequence do

  let(:pre_jobs) { [PreJob.new('a')]}

  context '#make_jobs' do
    subject { Sequence.new(pre_jobs).send(:make_jobs, pre_jobs) }

    context 'when job has single dependency' do
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
      let(:job) do
        dep_job = Job.new 'b'
        Job.new 'a', dep_job
      end

      it { is_expected.to be_nil }
    end

    context 'when dep_tickets are not nil' do
      let(:job) do
        job = Job.new 'a'
        dep_job1 = Job.new 'b'
        dep_job1.ticket = 1
        dep_job2 = Job.new 'c'
        dep_job2.ticket = 2
        job.dep_jobs = dep_job1
        job.dep_jobs = dep_job2
        job
      end

      it { is_expected.to eq 1 }
    end

  end

  context "#to_s" do
    subject { Sequence.new(pre_jobs).to_s }

    it { is_expected.to eq 'a' }
  end

  context 'when there is circular error' do
    in_out = [
        %w(ab ba),
        %w(abc b ca),
        %w(ab bc cd da),
        %w(abd bc cd da),
        %w(a bc cf da e fb),
        %w(a bce cf da e fb)
    ]

    in_out.each do |input|
      it 'raises error' do
        expect{ Sequence.new make_pre_jobs(input) }.to raise_error CircularDepError
      end
    end
  end

  context '#sort' do
    # more readable input
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
          # p seq.to_s
          dep_inputs.each do |jobs|
            job_ind = seq.to_s.index jobs[0]
            # check all dependencies
            jobs[1..-1].chars.each do |job_name|
              dep_ind = seq.to_s.index job_name
              # job has to be after its dependency
              expect(job_ind).to be > dep_ind
            end
          end
        end
      end
    end
  end


  private

  def make_pre_jobs input
    input.flat_map do |chars|
      # first is name
      name = chars[0]
      if chars.size > 1
        # other is dependency
        chars[1..-1].chars.map do |dep_name|
          PreJob.new name, dep_name
        end
      else
        # if it does not has dependencies create PreJob without it
        PreJob.new name
      end
    end
  end
end
