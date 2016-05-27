require './lib/sequence.rb'
require './lib/pre_job.rb'

RSpec.describe Sequence do

  context '#make_jobs' do
    subject { Sequence.new(pre_jobs).send(:make_jobs, pre_jobs) }

    context 'when everything is correct' do
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
        expect(job_a.dep_job.name).to eq 'b'
      end
    end
  end
end