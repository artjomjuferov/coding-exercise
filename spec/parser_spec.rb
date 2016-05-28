require './lib/parser.rb'

RSpec.describe Parser do

  it 'responds to #pre_jobs()' do
    expect(Parser.new('')).to respond_to :pre_jobs
  end

  context '#pre_jobs()' do
    let(:file_data) { "" }

    subject { Parser.new(file_data).pre_jobs }

    context 'when invalid data' do

      ['ab=>b', 'a==>b', 'a+b', 'a=>>b', '1=>a', 'a=>1', 'A=>a'].each do |line|
        let(:file_data) { line }

        it 'raises error' do
          expect{ subject }.to raise_error LineError
        end
      end
    end

    context 'when empty string given' do
      it { is_expected.to eq [] }
    end

    context 'when single job a' do
      ["a   =>  ", "a=>"].each do |data|
        let(:file_data) { data }
        it 'returns array with job a' do
          pre_job = subject.pop
          expect(pre_job.name).to eq 'a'
        end
        it 'returns array with job a' do
          pre_job = subject.pop
          dep_name = pre_job.dep_name
          expect(dep_name).to eq nil
        end
      end
    end

    context 'when a depends on b' do
      let(:file_data) { "a =>b\nb =>" }

      it { is_expected.to be_an_instance_of Array }

      it 'returns array with first job "a"' do
        job = subject[0]
        expect(job.name).to eq 'a'
      end

      it 'a depends on b' do
        job = subject[0]
        dep_name = job.dep_name
        expect(dep_name).to eq 'b'
      end

      it 'returns array with second job "b"' do
        job = subject[1]
        expect(job.name).to eq 'b'
      end
    end
  end
end 