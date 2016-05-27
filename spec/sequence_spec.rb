require './lib/sequence.rb'
require './lib/pre_job.rb'

RSpec.describe Sequence do

  let(:pre_jobs) { [PreJob.new('a')]}

  context '#make_jobs' do
    subject { Sequence.new(pre_jobs).send(:make_jobs, pre_jobs) }

    let(:pre_jobs) { [PreJob.new('a', 'b'), PreJob.new('b')]}

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
        expect(job_a.dep_job.name).to eq 'b'
      end
    end
  end

  context "#to_s" do
    subject { Sequence.new(pre_jobs).to_s }

    it { is_expected.to eq 'a' }
  end

  context '#sort' do
    context 'when without errors' do
      inputs = [
          %w(a),
          %w(a b c),
          %w(a bc c),
          %w(a bc cf da eb f)
      ]

      inputs.each do |input|
        context "when input = #{input}" do
          it 'returns right value' do
            pre_jobs = make_pre_jobs input
            seq = Sequence.new pre_jobs
            seq.sort
            # for checkin select only dependencies
            dep_inputs = input.select{|x| x.size == 2}
            dep_inputs.each do |jobs|
              job_ind = seq.to_s.index jobs[0]
              dep_ind = seq.to_s.index jobs[1]
              # job index has to be after
              expect(job_ind).to be > dep_ind
            end
          end
        end
      end
    end

    context 'when there is circular error' do
      in_out = [
          %w(a bc cf da e fb)
      ]

      in_out.each do |input|
        it 'raises error' do
          expect{ Sequence.new make_pre_jobs(input) }.to raise_error CircularDepError
        end
      end
    end
  end


  private

  def make_pre_jobs input
    input.map {|chars| PreJob.new chars[0], chars[1] }
  end
end
