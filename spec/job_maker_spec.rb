require './lib/job_maker.rb'


RSpec.describe JobMaker do

  context '#call' do
    subject { JobMaker.new(pre_jobs).call }

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
end
