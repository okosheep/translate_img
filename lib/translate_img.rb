# frozen_string_literal: true

require_relative "translate_img/version"
require 'aws-sdk'
require 'fastimage'
require 'cairo'

module TranslateImg
  # Translate image.
  # @params region [String] AWS region. Default is us-east-1.
  # @params src_file_path [String]
  # @params dest_file_path [String]
  def self.translate(region: 'us-east-1', src_file_path:, dest_file_path:)
    fail 'Source file and destination file must not be same.' if src_file_path === dest_file_path

    textract_client = Aws::Textract::Client.new(region: region)
    translate_client = Aws::Translate::Client.new

    detected = textract_client.detect_document_text({document: {bytes: open(src_file_path).read}})

    src_width, src_height = FastImage.size(src_file_path)
    filtered_blocks = detected.blocks.filter{ |block| block.text_type.nil? && !block.text.nil? }.map do |block|
      box = block.geometry.bounding_box
      translated = translate_client.translate_text(text: block.text, source_language_code: 'en', target_language_code: 'ja')
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
    context.set_source_color(Cairo::Color::GREEN)
    context.set_font_size(16)
    context.select_font_face('MigMix 1M')
    filtered_blocks.each do |filtered_block|
      context.rectangle(filtered_block.left, filtered_block.top, filtered_block.width, filtered_block.height)
      context.stroke
      context.move_to(filtered_block.left, filtered_block.top)
      context.show_text(filtered_block.text)
    end

    surface.write_to_png(dest_file_path)
  end
end
