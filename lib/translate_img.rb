# frozen_string_literal: true

require_relative "translate_img/version"
require 'aws-sdk'
require 'fastimage'
require 'cairo'

module TranslateImg
  class << self
    def configure
      yield(configuration)
    end

    def configuration
      @configuration ||= Configuration.new
    end

    class Configuration
      attr_accessor :aws_textract_region
      attr_accessor :aws_translate_region
      attr_accessor :font_face
      attr_accessor :font_size
      attr_accessor :font_color_rgba

      def initialize
        @aws_textract_region = 'us-east-1'
        @aws_translate_region = 'ap-northeast-1'
        @font_face = 'MigMix 1M'
        @font_size = 16
        @font_color_rgba = { red: 255, green: 0, blue: 0, alpha: 1 }
      end
    end

    # Translate image.
    # @param src_file_path [String]
    # @param dest_file_path [String]
    # @param source_language_code [String] Default is 'en'.
    # @param target_language_code [String] Default is 'ja'.
    def translate(src_file_path:, dest_file_path:, source_language_code: 'en', target_language_code: 'ja')
      fail 'Source file and destination file must not be same.' if src_file_path === dest_file_path

      textract_client = Aws::Textract::Client.new(region: TranslateImg.configuration.aws_textract_region)
      translate_client = Aws::Translate::Client.new(region: TranslateImg.configuration.aws_translate_region)

      detected = textract_client.detect_document_text({document: {bytes: open(src_file_path).read}})

      src_width, src_height = FastImage.size(src_file_path)
      filtered_blocks = detected.blocks.filter{ |block| block.text_type.nil? && !block.text.nil? }.map do |block|
        box = block.geometry.bounding_box
        # https://docs.aws.amazon.com/translate/latest/dg/what-is.html
        translated = translate_client.translate_text(text: block.text, source_language_code: source_language_code, target_language_code: target_language_code)
        OpenStruct.new(
          text: translated.translated_text,
          left: (box.left * src_width).ceil,
          top: (box.top * src_height).ceil,
          width: (box.width * src_width).ceil,
          height: (box.height * src_height).ceil,
        )
      end

      FileUtils.cp src_file_path, dest_file_path
      surface = Cairo::ImageSurface.from_png(dest_file_path)
      context = Cairo::Context.new(surface)
      context.set_source_rgba(*TranslateImg.configuration.font_color_rgba.slice(:red, :green, :blue, :alpha).values)
      context.set_font_size(TranslateImg.configuration.font_size)
      context.select_font_face(TranslateImg.configuration.font_face)
      filtered_blocks.each do |filtered_block|
        context.rectangle(filtered_block.left, filtered_block.top, filtered_block.width, filtered_block.height)
        context.stroke
        context.move_to(filtered_block.left, filtered_block.top)
        context.show_text(filtered_block.text)
      end

      surface.write_to_png(dest_file_path)
    end
  end
end
