# frozen_string_literal: true

RSpec.describe TranslateImg do
  it 'has a version number' do
    expect(TranslateImg::VERSION).not_to be nil
  end

  describe '.translate' do
    subject do
      TranslateImg.translate(
        src_file_path: src_file_path,
        dest_file_path: dest_file_path,
        source_language_code: source_language_code,
        target_language_code: target_language_code
      )
    end

    let(:src_file_path) { 'spec/test_data.png' }
    let(:dest_file_path) { 'spec/test_data2.png' }
    let(:source_language_code) { 'en' }
    let(:target_language_code) { 'ja' }

    after do
      FileUtils.remove dest_file_path if File.exist?(dest_file_path)
    end

    describe 'when valid parameters specified' do
      before do
        textract_mock = Object.new
        allow(textract_mock).to receive(:detect_document_text).and_return(
          OpenStruct.new(
            blocks: [OpenStruct.new(
              text_type: nil,
              text: 'hello',
              geometry: OpenStruct.new(
                bounding_box: OpenStruct.new(left: 0, top: 0, width: 0, height: 0)
              )
            )]
          )
        )
        allow(Aws::Textract::Client).to receive(:new).and_return(textract_mock)

        translate_mock = Object.new
        allow(translate_mock).to receive(:translate_text).and_return(
          OpenStruct.new(translated_text: 'こんにちは')
        )
        allow(Aws::Translate::Client).to receive(:new).and_return(translate_mock)
      end

      it { is_expected.to be_truthy }
    end

    xdescribe 'when a region that does not provide the service is specified' do
      before do
        TranslateImg.configure do |config|
          config.aws_textract_region = 'ap-northeast-1'
        end
      end

      it 'will generate a no such endpoint error' do
        expect{ subject }.to raise_error Aws::Errors::NoSuchEndpointError
      end
    end
  end
end
