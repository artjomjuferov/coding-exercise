require './lib/job.rb'

RSpec.describe Job do

  let(:name) { 'a' }

  let(:dep_job) { nil }

  subject { Job.new name, dep_job }

  context 'when dependency is not provided' do
    it { is_expected.to respond_to :name, :dep_job, :dep_job=, :ticket, :ticket=}

    it 'does not raise errors' do
      expect{ subject }.not_to raise_error
    end

    it 'has name "a"' do
      expect(subject.name).to eq 'a'
    end

    it 'has dep_job nil' do
      expect(subject.dep_job).to be_nil
    end
  end

  context 'when dependency is provided' do
    let(:dep_job) { Job.new 'b', nil }

    it { is_expected.to respond_to :name, :dep_job, :dep_job=, :ticket, :ticket=}

    it 'does not raise errors' do
      expect{ subject }.not_to raise_error
    end

    it 'has name "a"' do
      expect(subject.name).to eq 'a'
    end

    it 'has dependency job' do
      expect(subject.dep_job).to eq dep_job
    end

    it 'dependency job name is "b"' do
      expect(subject.dep_job.name).to eq 'b'
    end
  end
end

