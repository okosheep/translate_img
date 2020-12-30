# frozen_string_literal: true

RSpec.describe TranslateImg do
  it 'has a version number' do
    expect(TranslateImg::VERSION).not_to be nil
  end

  describe 'sandbox' do
    it { described_class.new}
  end

  it 'does something useful' do
    expect(false).to eq(true)
  end
end
