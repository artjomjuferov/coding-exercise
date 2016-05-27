require './lib/pre_job.rb'

RSpec.describe PreJob do
  let(:dep_name) { nil }

  subject { PreJob.new name, dep_name }

  context 'when dependency name is not provided' do
    context 'when wrong name' do
      %w(A я 1 + .).each do |wrong_name|
        let(:name){ wrong_name }

        it 'raises error' do
          expect{ subject }.to raise_error PreJobNameError
        end
      end
    end

    context 'when correct name' do
      let(:name){ "a" }

      it 'does not raise error' do
        expect{ subject }.not_to raise_error
      end

      it { is_expected.to respond_to :name, :dep_name}
      # it { is_expected.to respond_ro :dep_name}

      it 'has name eq "a"' do
        expect(subject.name).to eq 'a'
      end

      it 'does not have dep_name' do
        expect(subject.dep_name).to be_nil
      end
    end
  end
end