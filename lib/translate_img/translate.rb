# frozen_string_literal: true

require 'aws-sdk'
require 'fastimage'
require 'cairo'
require 'open-uri'

# Provides translation processing.
module TranslateImg
  class << self
    # Translate image.
    # @param src_file_path [String]
    # @param dest_file_path [String]
    # @param source_language_code [String] Default is 'en'.
    # @param target_language_code [String] Default is 'ja'.
    # @raise When src_file_path and dest_file_path are the same, a RuntimeError is raised.
    # @see https://docs.aws.amazon.com/translate/latest/dg/what-is.html
    # @note Since this method uses the services of Amazon Translate and Amazon Textract,
    # you will be charged for the use of each service.
    def translate(src_file_path:, dest_file_path:, source_language_code: 'en', target_language_code: 'ja')
      raise 'Source file and destination file must not be same.' if src_file_path == dest_file_path

      detected = amazon_textract_client.detect_document_text(document: { bytes: URI.open(src_file_path).read })
      filtered_blocks = filter_detected_blocks(detected: detected).map do |block|
        box = block.geometry.bounding_box
        translated = amazon_translate_client.translate_text(
          text: block.text,
          source_language_code: source_language_code,
          target_language_code: target_language_code,
        )
        generate_block src_file_path: src_file_path, box: box, translated: translated
      end

      draw_dest_file filtered_blocks: filtered_blocks, src_file_path: src_file_path, dest_file_path: dest_file_path
    end

    private

    # @return [Aws::Textract::Client]
    def amazon_textract_client
      Aws::Textract::Client.new(region: TranslateImg.configuration.aws_textract_region)
    end

    # @return [Aws::Translate::Client]
    def amazon_translate_client
      Aws::Translate::Client.new(region: TranslateImg.configuration.aws_translate_region)
    end

    # Filter detected blocks.
    # @param detected [Object]
    def filter_detected_blocks(detected:)
      detected.blocks.filter { |block| block.text_type.nil? && !block.text.nil? }
    end

    # Generate block.
    # @param src_file_path [String]
    # @param box [Object]
    # @param translated [Object]
    # @return [Hash]
    def generate_block(src_file_path:, box:, translated:)
      src_width, src_height = FastImage.size(src_file_path)
      {
        text: translated.translated_text,
        left: (box.left * src_width).ceil,
        top: (box.top * src_height).ceil,
        width: (box.width * src_width).ceil,
        height: (box.height * src_height).ceil,
      }
    end

    # Setup cairo surface and context.
    # @param dest_file_path [String]
    # @return [[Cairo::Surface, Cairo::Context]]
    def setup_surface(dest_file_path:)
      surface = Cairo::ImageSurface.from_png(dest_file_path)
      context = Cairo::Context.new(surface)
      context.set_source_rgba(*TranslateImg.configuration.font_color_rgba.slice(:red, :green, :blue, :alpha).values)
      context.set_font_size(TranslateImg.configuration.font_size)
      context.select_font_face(TranslateImg.configuration.font_face)
      [surface, context]
    end

    # Draw translated text to destination file.
    # @param filtered_blocks [Array]
    # @param src_file_path [String]
    # @param dest_file_path [String]
    # @return nil
    def draw_dest_file(filtered_blocks:, src_file_path:, dest_file_path:)
      FileUtils.cp src_file_path, dest_file_path
      surface, context = setup_surface(dest_file_path: dest_file_path)
      filtered_blocks.each do |filtered_block|
        context.rectangle(*filtered_block.slice(:left, :top, :width, :height).values)
        context.stroke
        context.move_to(*filtered_block.slice(:left, :top).values)
        context.show_text(filtered_block[:text])
      end

      surface.write_to_png(dest_file_path)
      nil
    rescue StandardError
      FileUtils.rm dest_file_path if File.exist?(dest_file_path)
      raise $ERROR_INFO
    end
  end
end
